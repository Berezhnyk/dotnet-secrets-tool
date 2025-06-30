# Contributing to GitLab Secrets Tool

Thank you for your interest in contributing to the GitLab Secrets Tool! This document provides guidelines and information for contributors.

## Development Setup

### Prerequisites

- .NET 8.0 SDK or later
- Git
- A code editor (VS Code, Visual Studio, etc.)

### Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/SecretsTool.git
   cd SecretsTool
   ```
3. Build the project:
   ```bash
   dotnet build --project SecretsTool.csproj
   ```
4. Run tests:
   ```bash
   make test
   ```

## Project Structure

```
SecretsTool/
├── .github/workflows/     # GitHub Actions workflows
├── scripts/              # Installation scripts
├── SecretsTool.csproj    # Main project file
├── Program.cs            # CLI entry point
├── GitLabSecretsTool.cs  # Core business logic
├── Models.cs             # Data models
└── README.md            # Documentation
```

## Development Guidelines

### Code Style

- Follow standard C# conventions
- Use nullable reference types
- Include XML documentation for public APIs
- Keep methods focused and single-purpose

### Testing

Before submitting a PR:

1. Build successfully: `dotnet build`
2. Test CLI functionality: `make test`
3. Verify cross-platform builds work
4. Test your changes manually

### Commit Messages

Use conventional commit format:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `ci:` for CI/CD changes
- `refactor:` for code refactoring

Example:
```
feat: add support for filtering variables by environment

- Add --environment parameter to filter variables
- Include global variables when filtering by environment
- Update help text and documentation
- Add validation for environment parameter
```

## Submitting Changes

### Pull Request Process

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

3. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a Pull Request on GitHub

### PR Requirements

- [ ] Code builds successfully
- [ ] All tests pass
- [ ] Documentation updated (if needed)
- [ ] Follows code style guidelines
- [ ] Includes appropriate tests
- [ ] PR description explains the changes

## Release Process

### Beta Releases

Maintainers can create beta releases using the GitHub Actions workflow:

1. Go to Actions → "Create Beta Release"
2. Run workflow with version like `1.0.0-beta.1`
3. Binaries are automatically built and published

### Production Releases

1. Update version in project files if needed
2. Create and push a tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. GitHub Actions automatically builds and publishes the release

## Feature Requests and Bug Reports

### Bug Reports

Please include:
- Operating system and version
- .NET version
- Command that was run
- Expected vs actual behavior
- Error messages or logs

### Feature Requests

Please include:
- Use case description
- Proposed solution
- Any alternative solutions considered
- Additional context

## Getting Help

- Create an issue for bugs or feature requests
- Start a discussion for questions or ideas
- Check existing issues before creating new ones

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Follow GitHub's community guidelines

Thank you for contributing! 🎉
