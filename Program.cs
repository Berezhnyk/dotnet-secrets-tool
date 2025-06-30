using System.CommandLine;
using System.Text.Json;
using System.Xml.Linq;

namespace SecretsTool;

public class Program
{
    public static async Task<int> Main(string[] args)
    {
        var projectIdOption = new Option<string>("--project-id", "GitLab project ID") { IsRequired = true };
        var tokenOption = new Option<string?>("--token", "GitLab Personal Access Token (can also use GITLAB_TOKEN env var)");
        var gitlabUrlOption = new Option<string>("--gitlab-url", () => "https://gitlab.com", "Base URL for GitLab API");
        var prefixOption = new Option<string?>("--prefix", "Prefix to filter variables");
        var environmentOption = new Option<string?>("--environment", "Filter variables by environment scope (includes variables that apply to all environments)");
        var userSecretsIdOption = new Option<string?>("--user-secrets-id", "Explicit UserSecretsId");
        var onlyNewOption = new Option<bool>("--only-new", "Only add variables that do not already exist in secrets.json");
        var verboseOption = new Option<bool>("--verbose", "Show detailed information about processed variables");

        var rootCommand = new RootCommand("Fetches GitLab CI/CD project-level variables and writes them to .NET user secrets storage")
        {
            projectIdOption,
            tokenOption,
            gitlabUrlOption,
            prefixOption,
            environmentOption,
            userSecretsIdOption,
            onlyNewOption,
            verboseOption
        };

        rootCommand.SetHandler(async (projectId, token, gitlabUrl, prefix, environment, userSecretsId, onlyNew, verbose) =>
        {
            try
            {
                var tool = new GitLabSecretsTool();
                await tool.ExecuteAsync(projectId, token, gitlabUrl, prefix, environment, userSecretsId, onlyNew, verbose);
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Error: {ex.Message}");
                Environment.Exit(1);
            }
        }, projectIdOption, tokenOption, gitlabUrlOption, prefixOption, environmentOption, userSecretsIdOption, onlyNewOption, verboseOption);

        return await rootCommand.InvokeAsync(args);
    }
}
