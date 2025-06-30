using System.Text.Json;
using System.Xml.Linq;

namespace SecretsTool;

public class GitLabSecretsTool
{
    private readonly HttpClient _httpClient;

    public GitLabSecretsTool()
    {
        _httpClient = new HttpClient();
    }

    public async Task ExecuteAsync(string projectId, string? token, string gitlabUrl, string? prefix, string? environment, string? userSecretsId, bool onlyNew, bool verbose = false)
    {
        // Validate inputs
        var accessToken = token ?? Environment.GetEnvironmentVariable("GITLAB_TOKEN");
        if (string.IsNullOrEmpty(accessToken))
        {
            throw new InvalidOperationException("GitLab token is required. Provide it via --token argument or GITLAB_TOKEN environment variable.");
        }

        if (string.IsNullOrEmpty(projectId))
        {
            throw new InvalidOperationException("Project ID is required.");
        }

        // Get or find UserSecretsId
        var secretsId = userSecretsId ?? FindUserSecretsId();
        if (string.IsNullOrEmpty(secretsId))
        {
            throw new InvalidOperationException("UserSecretsId not found. Either provide it via --user-secrets-id or ensure a .csproj file with UserSecretsId exists in the current directory.");
        }

        Console.WriteLine($"Using UserSecretsId: {secretsId}");

        // Fetch GitLab variables
        var variables = await FetchGitLabVariablesAsync(gitlabUrl, projectId, accessToken, verbose);
        Console.WriteLine($"Fetched {variables.Count} variables from GitLab");

        // Filter variables by prefix if specified
        if (!string.IsNullOrEmpty(prefix))
        {
            var beforeFilter = variables.Count;
            variables = variables.Where(v => v.Key.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)).ToList();
            Console.WriteLine($"Filtered by prefix '{prefix}': {beforeFilter} -> {variables.Count} variables");
        }

        // Filter variables by environment if specified
        if (!string.IsNullOrEmpty(environment))
        {
            var beforeFilter = variables.Count;
            variables = variables.Where(v => 
                string.IsNullOrEmpty(v.EnvironmentScope) || 
                v.EnvironmentScope == "*" || 
                string.Equals(v.EnvironmentScope, environment, StringComparison.OrdinalIgnoreCase)
            ).ToList();
            Console.WriteLine($"Filtered by environment '{environment}': {beforeFilter} -> {variables.Count} variables (including global variables)");
        }

        // Get existing secrets
        var secretsPath = GetSecretsPath(secretsId);
        var existingSecrets = await ReadExistingSecretsAsync(secretsPath);

        // Merge secrets
        var (addedCount, skippedCount) = MergeSecrets(existingSecrets, variables, onlyNew, verbose);

        // Write secrets back
        await WriteSecretsAsync(secretsPath, existingSecrets);

        // Print summary
        Console.WriteLine($"Summary:");
        Console.WriteLine($"  - Processed {variables.Count} variables (after filtering)");
        Console.WriteLine($"  - Added {addedCount} new secrets");
        if (onlyNew && skippedCount > 0)
        {
            Console.WriteLine($"  - Skipped {skippedCount} already existing keys");
        }
        
        // Check for duplicate keys across different environments
        var keyGroups = variables.GroupBy(v => v.Key).Where(g => g.Count() > 1).ToList();
        if (keyGroups.Any())
        {
            Console.WriteLine($"  - Note: {keyGroups.Count} key(s) had multiple values for different environments (last value wins)");
            if (verbose)
            {
                foreach (var group in keyGroups)
                {
                    Console.WriteLine($"    • {group.Key}: {string.Join(", ", group.Select(v => v.EnvironmentScope ?? "*"))} environments");
                }
            }
        }
        
        Console.WriteLine($"Secrets written to: {secretsPath}");
    }

    private async Task<List<GitLabVariable>> FetchGitLabVariablesAsync(string gitlabUrl, string projectId, string accessToken, bool verbose = false)
    {
        var baseApiUrl = $"{gitlabUrl.TrimEnd('/')}/api/v4/projects/{projectId}/variables";
        
        _httpClient.DefaultRequestHeaders.Clear();
        _httpClient.DefaultRequestHeaders.Add("PRIVATE-TOKEN", accessToken);

        var allVariables = new List<GitLabVariable>();
        var page = 1;
        var perPage = 100; // Maximum allowed by GitLab API

        try
        {
            while (true)
            {
                var apiUrl = $"{baseApiUrl}?page={page}&per_page={perPage}";
                if (verbose)
                    Console.WriteLine($"Fetching page {page} from GitLab API...");

                var response = await _httpClient.GetAsync(apiUrl);
                
                if (!response.IsSuccessStatusCode)
                {
                    var errorContent = await response.Content.ReadAsStringAsync();
                    throw new HttpRequestException($"GitLab API request failed with status {response.StatusCode}: {errorContent}");
                }

                var jsonContent = await response.Content.ReadAsStringAsync();
                var variables = JsonSerializer.Deserialize(jsonContent, AppJsonSerializerContext.Default.ListJsonElement);

                if (variables == null || !variables.Any())
                {
                    // No more pages
                    break;
                }

                foreach (var variable in variables)
                {
                    var key = variable.GetProperty("key").GetString() ?? "";
                    var value = variable.GetProperty("value").GetString() ?? "";
                    var protectedProp = variable.TryGetProperty("protected", out var protectedEl) ? protectedEl.GetBoolean() : false;
                    var maskedProp = variable.TryGetProperty("masked", out var maskedEl) ? maskedEl.GetBoolean() : false;
                    var environmentScope = variable.TryGetProperty("environment_scope", out var envEl) ? envEl.GetString() : null;

                    // Skip variables with empty keys
                    if (string.IsNullOrWhiteSpace(key))
                    {
                        if (verbose)
                            Console.WriteLine("Warning: Skipping variable with empty key");
                        continue;
                    }

                    if (verbose)
                    {
                        Console.WriteLine($"  Variable: {key} (env: {environmentScope ?? "*"}, protected: {protectedProp}, masked: {maskedProp})");
                    }

                    allVariables.Add(new GitLabVariable(key, value, protectedProp, maskedProp, environmentScope));
                }

                // Check if we got fewer results than requested, indicating the last page
                if (variables.Count() < perPage)
                {
                    break;
                }

                page++;
            }

            if (verbose)
                Console.WriteLine($"Fetched {allVariables.Count} total variables from {page} page(s)");

            return allVariables;
        }
        catch (HttpRequestException)
        {
            throw;
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"Failed to fetch variables from GitLab: {ex.Message}", ex);
        }
    }

    private string? FindUserSecretsId()
    {
        var currentDir = Directory.GetCurrentDirectory();
        var csprojFiles = Directory.GetFiles(currentDir, "*.csproj");

        foreach (var csprojFile in csprojFiles)
        {
            try
            {
                var doc = XDocument.Load(csprojFile);
                var userSecretsId = doc.Descendants("UserSecretsId").FirstOrDefault()?.Value;
                if (!string.IsNullOrEmpty(userSecretsId))
                {
                    return userSecretsId;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Warning: Could not read {csprojFile}: {ex.Message}");
            }
        }

        return null;
    }

    private string GetSecretsPath(string userSecretsId)
    {
        string basePath;
        
        if (OperatingSystem.IsWindows())
        {
            basePath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            return Path.Combine(basePath, "Microsoft", "UserSecrets", userSecretsId, "secrets.json");
        }
        else
        {
            var homeDir = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
            return Path.Combine(homeDir, ".microsoft", "usersecrets", userSecretsId, "secrets.json");
        }
    }

    private async Task<Dictionary<string, string>> ReadExistingSecretsAsync(string secretsPath)
    {
        if (!File.Exists(secretsPath))
        {
            // Create directory if it doesn't exist
            var directory = Path.GetDirectoryName(secretsPath);
            if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
            {
                Directory.CreateDirectory(directory);
            }
            return new Dictionary<string, string>();
        }

        try
        {
            var jsonContent = await File.ReadAllTextAsync(secretsPath);
            if (string.IsNullOrWhiteSpace(jsonContent))
            {
                return new Dictionary<string, string>();
            }

            var secrets = JsonSerializer.Deserialize(jsonContent, AppJsonSerializerContext.Default.DictionaryStringString);
            return secrets ?? new Dictionary<string, string>();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Warning: Could not read existing secrets file: {ex.Message}");
            return new Dictionary<string, string>();
        }
    }

    private (int addedCount, int skippedCount) MergeSecrets(Dictionary<string, string> existingSecrets, List<GitLabVariable> variables, bool onlyNew, bool verbose = false)
    {
        int addedCount = 0;
        int skippedCount = 0;

        if (verbose)
            Console.WriteLine($"Merging {variables.Count} variables (onlyNew: {onlyNew})");
        if (verbose)
            Console.WriteLine($"Existing secrets count: {existingSecrets.Count}");

        foreach (var variable in variables)
        {
            if (onlyNew && existingSecrets.ContainsKey(variable.Key))
            {
                if (verbose)
                    Console.WriteLine($"  Skipping existing key: {variable.Key}");
                skippedCount++;
                continue;
            }

            var isOverwriting = existingSecrets.ContainsKey(variable.Key);
            if (isOverwriting && verbose)
            {
                Console.WriteLine($"  Overwriting key: {variable.Key} (previous environment may be different)");
            }
            else if (verbose)
            {
                Console.WriteLine($"  Adding new key: {variable.Key}");
            }

            existingSecrets[variable.Key] = variable.Value;
            addedCount++;
        }

        if (verbose)
            Console.WriteLine($"Final secrets count: {existingSecrets.Count}");
        return (addedCount, skippedCount);
    }

    private async Task WriteSecretsAsync(string secretsPath, Dictionary<string, string> secrets)
    {
        // Ensure directory exists
        var directory = Path.GetDirectoryName(secretsPath);
        if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
        {
            Directory.CreateDirectory(directory);
        }

        var options = new JsonSerializerOptions
        {
            WriteIndented = true,
            TypeInfoResolver = AppJsonSerializerContext.Default
        };

        var jsonContent = JsonSerializer.Serialize(secrets, options);
        await File.WriteAllTextAsync(secretsPath, jsonContent);
    }

    public void Dispose()
    {
        _httpClient?.Dispose();
    }
}
