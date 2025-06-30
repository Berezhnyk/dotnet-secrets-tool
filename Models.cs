using System.Text.Json;
using System.Text.Json.Serialization;

namespace SecretsTool;

public record GitLabVariable(string Key, string Value, bool Protected, bool Masked, string? EnvironmentScope);

public class GitLabApiResponse
{
    public List<GitLabVariable> Variables { get; set; } = new();
}

[JsonSerializable(typeof(List<JsonElement>))]
[JsonSerializable(typeof(Dictionary<string, string>))]
[JsonSerializable(typeof(GitLabVariable))]
[JsonSerializable(typeof(List<GitLabVariable>))]
public partial class AppJsonSerializerContext : JsonSerializerContext
{
}
