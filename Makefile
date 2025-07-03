# Makefile for GitLab Secrets Tool

# Configuration
PROJECT_NAME = SecretsTool
DOTNET_VERSION = net8.0
CONFIGURATION = Release
PUBLISH_DIR = ./publish

# Detect platform
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

ifeq ($(UNAME_S),Darwin)
    ifeq ($(UNAME_M),arm64)
        RUNTIME = osx-arm64
    else
        RUNTIME = osx-x64
    endif
    PLATFORM = macos
    EXECUTABLE = $(PROJECT_NAME)
else ifeq ($(UNAME_S),Linux)
    RUNTIME = linux-x64
    PLATFORM = linux
    EXECUTABLE = $(PROJECT_NAME)
else
    RUNTIME = win-x64
    PLATFORM = windows
    EXECUTABLE = $(PROJECT_NAME).exe
endif

# Default target
.PHONY: all
all: build

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	dotnet clean
	rm -rf $(PUBLISH_DIR)
	rm -rf bin obj
	rm -rf dist

# Clean everything including sensitive files
.PHONY: clean-all
clean-all: clean
	@echo "Cleaning sensitive files..."
	./scripts/cleanup.sh

# Restore dependencies
.PHONY: restore
restore:
	@echo "Restoring dependencies..."
	dotnet restore

# Build the project
.PHONY: build
build: restore
	@echo "Building $(PROJECT_NAME)..."
	dotnet build --configuration $(CONFIGURATION) --no-restore

# Test the project
.PHONY: test
test: build
	@echo "Running tests..."
	dotnet test --configuration $(CONFIGURATION) --no-build

# Publish single-file executable for current platform
.PHONY: publish
publish: build
	@echo "Publishing $(PROJECT_NAME) for $(RUNTIME)..."
	dotnet publish \
		--configuration $(CONFIGURATION) \
		--runtime $(RUNTIME) \
		--self-contained true \
		--output $(PUBLISH_DIR)/$(RUNTIME) \
		-p:PublishSingleFile=true \
		-p:PublishTrimmed=true \
		-p:TrimMode=link

# Publish for all platforms
.PHONY: publish-all
publish-all: build
	@echo "Publishing $(PROJECT_NAME) for all platforms..."
	
	# Windows x64
	dotnet publish \
		--configuration $(CONFIGURATION) \
		--runtime win-x64 \
		--self-contained true \
		--output $(PUBLISH_DIR)/win-x64 \
		-p:PublishSingleFile=true \
		-p:PublishTrimmed=true \
		-p:TrimMode=link
	
	# Windows ARM64
	dotnet publish \
		--configuration $(CONFIGURATION) \
		--runtime win-arm64 \
		--self-contained true \
		--output $(PUBLISH_DIR)/win-arm64 \
		-p:PublishSingleFile=true \
		-p:PublishTrimmed=true \
		-p:TrimMode=link
	
	# macOS x64
	dotnet publish \
		--configuration $(CONFIGURATION) \
		--runtime osx-x64 \
		--self-contained true \
		--output $(PUBLISH_DIR)/osx-x64 \
		-p:PublishSingleFile=true \
		-p:PublishTrimmed=true \
		-p:TrimMode=link
	
	# macOS ARM64
	dotnet publish \
		--configuration $(CONFIGURATION) \
		--runtime osx-arm64 \
		--self-contained true \
		--output $(PUBLISH_DIR)/osx-arm64 \
		-p:PublishSingleFile=true \
		-p:PublishTrimmed=true \
		-p:TrimMode=link
	
	# Linux x64
	dotnet publish \
		--configuration $(CONFIGURATION) \
		--runtime linux-x64 \
		--self-contained true \
		--output $(PUBLISH_DIR)/linux-x64 \
		-p:PublishSingleFile=true \
		-p:PublishTrimmed=true \
		-p:TrimMode=link

# Code sign macOS binaries (requires Apple Developer Certificate)
.PHONY: codesign-macos
codesign-macos:
	@echo "Code signing macOS binaries..."
	@if [ "$(PLATFORM)" = "macos" ]; then \
		if [ -f "$(PUBLISH_DIR)/osx-x64/$(PROJECT_NAME)" ]; then \
			./scripts/codesign-macos.sh $(PUBLISH_DIR)/osx-x64/$(PROJECT_NAME); \
		fi; \
		if [ -f "$(PUBLISH_DIR)/osx-arm64/$(PROJECT_NAME)" ]; then \
			./scripts/codesign-macos.sh $(PUBLISH_DIR)/osx-arm64/$(PROJECT_NAME); \
		fi; \
	else \
		echo "Code signing is only available on macOS"; \
	fi

# Create distribution archives
.PHONY: dist
dist: publish-all
	@echo "Creating distribution archives..."
	@mkdir -p dist
	
	# Windows archives
	@if [ -f "$(PUBLISH_DIR)/win-x64/$(PROJECT_NAME).exe" ]; then \
		cd $(PUBLISH_DIR)/win-x64 && zip -q ../../dist/secretstool-win-x64.zip $(PROJECT_NAME).exe; \
	fi
	@if [ -f "$(PUBLISH_DIR)/win-arm64/$(PROJECT_NAME).exe" ]; then \
		cd $(PUBLISH_DIR)/win-arm64 && zip -q ../../dist/secretstool-win-arm64.zip $(PROJECT_NAME).exe; \
	fi
	
	# macOS archives
	@if [ -f "$(PUBLISH_DIR)/osx-x64/$(PROJECT_NAME)" ]; then \
		cd $(PUBLISH_DIR)/osx-x64 && chmod +x $(PROJECT_NAME) && tar -czf ../../dist/secretstool-macos-x64.tar.gz $(PROJECT_NAME); \
	fi
	@if [ -f "$(PUBLISH_DIR)/osx-arm64/$(PROJECT_NAME)" ]; then \
		cd $(PUBLISH_DIR)/osx-arm64 && chmod +x $(PROJECT_NAME) && tar -czf ../../dist/secretstool-macos-arm64.tar.gz $(PROJECT_NAME); \
	fi
	
	# Linux archives
	@if [ -f "$(PUBLISH_DIR)/linux-x64/$(PROJECT_NAME)" ]; then \
		cd $(PUBLISH_DIR)/linux-x64 && chmod +x $(PROJECT_NAME) && tar -czf ../../dist/secretstool-linux-x64.tar.gz $(PROJECT_NAME); \
	fi

# Create signed distribution (macOS only)
.PHONY: dist-signed
dist-signed: publish-all codesign-macos
	@echo "Creating signed distribution archives..."
	@mkdir -p dist
	
	# Windows archives (unsigned)
	@if [ -f "$(PUBLISH_DIR)/win-x64/$(PROJECT_NAME).exe" ]; then \
		cd $(PUBLISH_DIR)/win-x64 && zip -q ../../dist/secretstool-win-x64.zip $(PROJECT_NAME).exe; \
	fi
	@if [ -f "$(PUBLISH_DIR)/win-arm64/$(PROJECT_NAME).exe" ]; then \
		cd $(PUBLISH_DIR)/win-arm64 && zip -q ../../dist/secretstool-win-arm64.zip $(PROJECT_NAME).exe; \
	fi
	
	# macOS archives (signed)
	@if [ -f "$(PUBLISH_DIR)/osx-x64/$(PROJECT_NAME)" ]; then \
		cd $(PUBLISH_DIR)/osx-x64 && chmod +x $(PROJECT_NAME) && tar -czf ../../dist/secretstool-macos-x64.tar.gz $(PROJECT_NAME); \
	fi
	@if [ -f "$(PUBLISH_DIR)/osx-arm64/$(PROJECT_NAME)" ]; then \
		cd $(PUBLISH_DIR)/osx-arm64 && chmod +x $(PROJECT_NAME) && tar -czf ../../dist/secretstool-macos-arm64.tar.gz $(PROJECT_NAME); \
	fi
	
	# Linux archives (unsigned)
	@if [ -f "$(PUBLISH_DIR)/linux-x64/$(PROJECT_NAME)" ]; then \
		cd $(PUBLISH_DIR)/linux-x64 && chmod +x $(PROJECT_NAME) && tar -czf ../../dist/secretstool-linux-x64.tar.gz $(PROJECT_NAME); \
	fi

# Install locally (for testing)
.PHONY: install
install: publish
	@echo "Installing $(PROJECT_NAME) locally..."
	@mkdir -p ~/.local/bin
	@cp $(PUBLISH_DIR)/$(RUNTIME)/$(EXECUTABLE) ~/.local/bin/
	@chmod +x ~/.local/bin/$(EXECUTABLE)
	@echo "$(PROJECT_NAME) installed to ~/.local/bin/"
	@echo "Make sure ~/.local/bin is in your PATH"

# Run the application
.PHONY: run
run: build
	@echo "Running $(PROJECT_NAME)..."
	dotnet run --configuration $(CONFIGURATION) --no-build -- --help

# Show help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all           - Build the project (default)"
	@echo "  clean         - Clean build artifacts"
	@echo "  clean-all     - Clean build artifacts and sensitive files"
	@echo "  restore       - Restore dependencies"
	@echo "  build         - Build the project"
	@echo "  test          - Run tests"
	@echo "  publish       - Publish single-file executable for current platform"
	@echo "  publish-all   - Publish for all platforms"
	@echo "  codesign-macos - Code sign macOS binaries (requires Apple Developer Certificate)"
	@echo "  dist          - Create distribution archives"
	@echo "  dist-signed   - Create signed distribution archives (macOS only)"
	@echo "  install       - Install locally for testing"
	@echo "  run           - Run the application"
	@echo "  help          - Show this help message"
