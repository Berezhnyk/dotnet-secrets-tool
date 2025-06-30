using System.Text.Json;

namespace SecretsTool;

public record GitLabVariable(string Key, string Value, bool Protected, bool Masked, string? EnvironmentScope);

public class GitLabApiResponse
{
    public List<GitLabVariable> Variables { get; set; } = new();
}
