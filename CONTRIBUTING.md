# Contributing to Bindplane Deployment Examples

Thank you for your interest in contributing to Bindplane Deployment Examples!
This document outlines the development setup and contribution guidelines.

## Development Setup

### Prerequisites

- Git
- Python 3.7+ (for pre-commit)
- Terraform 1.5.7+
- Docker and Docker Compose
- [pre-commit](https://pre-commit.com/) for git hooks

### Setting Up Pre-commit Hooks

We use pre-commit hooks to ensure code quality and consistency. To set up pre-commit:

1. Install pre-commit:

```bash
# Using pip
pip install pre-commit

# Using Homebrew (macOS)
brew install pre-commit
```

1. Install the git hooks:

```bash
pre-commit install --install-hooks
pre-commit install --hook-type commit-msg  # For commit message validation
```

1. Install hook dependencies:

```bash
# For macOS users, if you need the Checkov hook
brew install rust  # Required for some hooks

# Install all hook dependencies
pre-commit install-hooks
```

1. To run the hooks manually (without committing):

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run a specific hook on all files
pre-commit run terraform_fmt --all-files

# Run a specific hook on specific files
pre-commit run terraform_fmt --files terraform/gcp/modules/cloudsql/main.tf
```

### Troubleshooting Pre-commit

If you encounter issues with specific hooks:

- **Rust-dependent hooks** (like Checkov): Ensure Rust is installed (`brew install rust`)
- **Terraform validation errors**: Fix the provider configuration issues in the Terraform files
- **Skip hooks temporarily**: Use `git commit --no-verify` (use sparingly)

### Pre-commit Hooks Overview

The following checks are performed on each commit:

- **General**:

  - Trim trailing whitespace
  - Fix end of files
  - Check YAML syntax
  - Check for large files
  - Detect secrets with Gitleaks
  - Lint Markdown files with markdownlint

- **Terraform**:

  - Format Terraform files (`terraform fmt`)
  - Validate Terraform configurations (`terraform validate`)
  - Update Terraform documentation

- **Docker**:

  - Validate Docker Compose files

- **Security**:

  - Scan Terraform files with Checkov
  - Detect secrets and sensitive information with Gitleaks

- **Commit Messages**:
  - Validate commit messages using Commitizen (conventional commits format)

## Contribution Guidelines

### Pull Request Process

1. Fork the repository and create your branch from `main`.
2. If you've added code, add tests and ensure your code passes all tests.
3. Update documentation as necessary.
4. Submit a pull request, describing the changes and the problem or enhancement it addresses.

### Coding Standards

- **Terraform**:

  - Follow Terraform's style conventions (enforced by `terraform fmt`)
  - Use standard module structure
  - Document all modules with READMEs
  - Use consistent resource naming

- **Docker**:

  - Ensure all Docker Compose files are valid and can be started
  - Document service configuration options
  - Follow best practices for Docker image security

- **Commit Messages**:
  - Follow the [Conventional Commits specification](https://www.conventionalcommits.org/)
  - Format: `<type>(<scope>): <description>`
  - Example: `feat(terraform): add GKE autopilot support`

### Continuous Integration

Our GitHub Actions workflows perform the following checks automatically:

- **Terraform Validation**:

  - Format verification
  - Configuration validation
  - Plugin caching for faster runs

- **Security Scanning**:

  - Terraform security scanning with TFSec and Checkov
  - Docker Compose validation
  - Docker configuration scanning with Trivy

- **Docker Compose Validation**:

  - Basic configuration validation
  - Dockerfile linting with Hadolint

- **Dependency Management**:
  - Dependabot automatically updates dependencies
  - Updates for GitHub Actions, Docker, Terraform providers, and more

## Using Conventional Commits

We use the Conventional Commits format for commit messages to make the change
history more readable and facilitate automatic versioning and changelog generation.

Format: `<type>(<scope>): <description>`

Types:

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

Example commit messages:

- `feat(gke): add support for GKE autopilot`
- `fix(cloudsql): resolve stale data issue in database updates`
- `docs(readme): update deployment instructions`

## License

By contributing, you agree that your contributions will be licensed under the project's license.
