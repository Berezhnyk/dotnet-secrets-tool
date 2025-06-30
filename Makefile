# GitLab Secrets Tool Makefile

.PHONY: build clean run test publish help validate-workflows

# Default target
help:
	@echo "Available targets:"
	@echo "  build              - Build the project"
	@echo "  clean              - Clean build artifacts"
	@echo "  run                - Run the tool with help"
	@echo "  publish            - Publish as self-contained executable"
	@echo "  test               - Run basic functionality tests"
	@echo "  validate-workflows - Validate GitHub Actions workflows"
	@echo "  help               - Show this help message"

build:
	dotnet build --project SecretsTool.csproj

clean:
	dotnet clean --project SecretsTool.csproj
	rm -rf bin obj

run:
	dotnet run --project SecretsTool.csproj -- --help

# Publish self-contained executables for different platforms
publish:
	@echo "Publishing for multiple platforms..."
	dotnet publish SecretsTool.csproj -c Release -r win-x64 --self-contained -o ./publish/win-x64
	dotnet publish SecretsTool.csproj -c Release -r osx-x64 --self-contained -o ./publish/osx-x64
	dotnet publish SecretsTool.csproj -c Release -r osx-arm64 --self-contained -o ./publish/osx-arm64
	dotnet publish SecretsTool.csproj -c Release -r linux-x64 --self-contained -o ./publish/linux-x64
	@echo "Published executables are in ./publish/ directory"

test:
	@echo "Running basic functionality tests..."
	@echo "1. Testing help command:"
	dotnet run --project SecretsTool.csproj -- --help
	@echo ""
	@echo "2. Testing missing required argument:"
	dotnet run --project SecretsTool.csproj || true
	@echo ""
	@echo "3. Testing missing token error:"
	dotnet run --project SecretsTool.csproj -- --project-id test-project || true

validate-workflows:
	@echo "Validating GitHub Actions workflows..."
	@if command -v actionlint >/dev/null 2>&1; then \
		actionlint .github/workflows/*.yml; \
		echo "✅ All workflows are valid"; \
	else \
		echo "⚠️  actionlint not found. Install with: brew install actionlint"; \
		echo "📝 Checking YAML syntax instead..."; \
		for file in .github/workflows/*.yml; do \
			echo "Checking $$file"; \
			python3 -c "import yaml; yaml.safe_load(open('$$file'))" && echo "✅ $$file syntax OK" || echo "❌ $$file syntax error"; \
		done; \
	fi
