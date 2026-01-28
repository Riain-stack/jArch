# Contributing to jArch

Thank you for your interest in contributing to jArch! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Style Guidelines](#style-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Report unacceptable behavior

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report:
1. Check existing issues to avoid duplicates
2. Collect relevant information (version, logs, steps to reproduce)
3. Use the bug report template

### Suggesting Features

Before suggesting a feature:
1. Check if it's already been suggested
2. Explain the use case and benefits
3. Consider implementation complexity
4. Use the feature request template

### Contributing Code

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Add tests if applicable
5. Ensure all tests pass
6. Commit with clear messages
7. Push and create a PR

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/jArch.git
cd jArch

# Add upstream remote
git remote add upstream https://github.com/Riain-stack/jArch.git

# Create a branch
git checkout -b feature/my-feature
```

## Style Guidelines

### Bash Scripts

- Use 4-space indentation
- Add error handling with `set -eo pipefail`
- Quote variables: `"$VARIABLE"`
- Use functions for reusability
- Add comments for complex logic
- Follow existing patterns

Example:
```bash
#!/usr/bin/env bash
set -eo pipefail

my_function() {
    local param="$1"
    
    if [[ -z "$param" ]]; then
        echo "Error: parameter required"
        return 1
    fi
    
    # Do something
    echo "Processing: $param"
}
```

### Neovim Lua

- Use 4-space indentation
- Follow Lua best practices
- Keep plugins modular
- Document keybindings

### Configuration Files

- Use appropriate indentation (see `.editorconfig`)
- Keep files organized and commented
- Follow existing structure

## Testing

### Running Tests

```bash
# Run all tests
./tests/test-step-counting.sh
./tests/test-profile-logic.sh
./tests/test-component-mapping.sh

# Syntax check
bash -n install/install.sh

# Dry-run test
sudo ./install/install.sh --dry-run --profile minimal
```

### Writing Tests

- Add tests for new features
- Ensure tests are reproducible
- Use clear test names
- Test edge cases

Example test structure:
```bash
#!/usr/bin/env bash
set -e

test_my_feature() {
    local expected="value"
    local actual=$(my_function)
    
    if [[ "$actual" == "$expected" ]]; then
        echo "✓ PASS - my_feature test"
    else
        echo "✗ FAIL - Expected: $expected, Got: $actual"
        exit 1
    fi
}

test_my_feature
```

## Pull Request Process

1. **Update Documentation**
   - Update README.md if needed
   - Update CHANGELOG.md with your changes
   - Add comments to complex code

2. **Run Tests**
   - Ensure all existing tests pass
   - Add new tests for new features
   - Test on clean Arch installation if possible

3. **Commit Messages**
   Follow conventional commits format:
   ```
   type(scope): description
   
   Longer explanation if needed
   
   Fixes #123
   ```
   
   Types: `feat`, `fix`, `docs`, `test`, `chore`, `refactor`
   
   Examples:
   - `feat(installer): add package group support`
   - `fix(backup): handle missing directories gracefully`
   - `docs(readme): update installation instructions`

4. **PR Description**
   - Describe what and why
   - Reference related issues
   - List changes made
   - Include testing done
   - Use the PR template

5. **Review Process**
   - Address reviewer feedback
   - Keep discussions focused
   - Be open to suggestions
   - Update PR as needed

## Project Structure

```
jArch/
├── install/
│   └── install.sh          # Main installer script
├── dotfiles/
│   └── .config/            # Configuration files
│       ├── niri/           # Niri WM config
│       ├── nvim/           # Neovim config
│       ├── zsh/            # Zsh config
│       ├── ripgrep/        # Ripgrep config
│       └── starship.toml   # Starship prompt
├── tests/                  # Test scripts
├── backup.sh               # Backup script
├── restore.sh              # Restore script
├── README.md               # Main documentation
├── INSTALL.md              # Installation guide
├── CHANGELOG.md            # Version history
└── CONTRIBUTING.md         # This file
```

## Areas Needing Help

- [ ] Testing on different hardware configurations
- [ ] Documentation improvements
- [ ] Additional theme support
- [ ] More package groups
- [ ] Performance optimizations
- [ ] Bug fixes and error handling
- [ ] Localization/i18n

## Getting Help

- Open an issue for questions
- Check existing documentation
- Review closed issues for solutions
- Ask in discussions (if enabled)

## Recognition

Contributors will be:
- Listed in release notes
- Credited in CHANGELOG.md
- Acknowledged in the project

Thank you for contributing to jArch! 🎉
