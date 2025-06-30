# Setting up User Secrets in Your .NET Project

To use this tool with your .NET project, you need to configure User Secrets. Here's how:

## Method 1: Using .NET CLI (Recommended)

1. Navigate to your project directory
2. Initialize user secrets:
   ```bash
   dotnet user-secrets init
   ```

This will automatically add a `<UserSecretsId>` element to your `.csproj` file.

## Method 2: Manual Configuration

Add the following to your `.csproj` file inside a `<PropertyGroup>`:

```xml
<PropertyGroup>
  <UserSecretsId>your-unique-secrets-id-here</UserSecretsId>
</PropertyGroup>
```

Replace `your-unique-secrets-id-here` with a unique GUID or string.

## Example .csproj File

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <UserSecretsId>my-app-secrets-12345</UserSecretsId>
  </PropertyGroup>

</Project>
```

## Verifying User Secrets

You can verify your user secrets are working by:

1. Adding a test secret:
   ```bash
   dotnet user-secrets set "TestKey" "TestValue"
   ```

2. Listing all secrets:
   ```bash
   dotnet user-secrets list
   ```

3. Removing the test secret:
   ```bash
   dotnet user-secrets remove "TestKey"
   ```

## Using Secrets in Your Application

In your `Program.cs` or `Startup.cs`, the configuration automatically includes user secrets in development:

```csharp
var builder = WebApplication.CreateBuilder(args);

// User secrets are automatically loaded in development
var mySecret = builder.Configuration["MySecretKey"];
```

For console applications, you need to explicitly add user secrets:

```csharp
var configuration = new ConfigurationBuilder()
    .AddUserSecrets<Program>()
    .Build();

var mySecret = configuration["MySecretKey"];
```

## Advanced Usage with GitLab Secrets Tool

When using the GitLab Secrets Tool with your project, you can take advantage of additional filtering options:

### Environment-Specific Variables

If your GitLab project has variables scoped to different environments, you can filter them:

```bash
# Only get production variables (plus global variables)
SecretsTool --project-id 12345 --environment production

# Only get staging variables (plus global variables)  
SecretsTool --project-id 12345 --environment staging

# Combine with prefix filtering
SecretsTool --project-id 12345 --environment production --prefix API_
```

The tool automatically includes:
- Variables specific to the requested environment
- Global variables (scope = "*" or empty)

This ensures you get both environment-specific secrets and global secrets that should be available everywhere.
