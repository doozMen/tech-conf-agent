# Contributing to Tech Conference MCP Server

Thank you for your interest in contributing to the Tech Conference MCP Server! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Code Style](#code-style)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)

## Code of Conduct

This project adheres to the Contributor Covenant Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

Before you begin:

- Make sure you have Swift 6.2+ installed on macOS 15.0+
- Familiarize yourself with the [Model Context Protocol (MCP)](https://modelcontextprotocol.io)
- Review the project documentation in `CLAUDE.md` and `USAGE.md`

## Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/doozMen/tech-conf-agent.git
cd tech-conf-agent
```

### 2. Build the Project

```bash
# Debug build
swift build

# Release build
swift build -c release
```

### 3. Run Tests

```bash
swift test
```

### 4. Install Locally

```bash
# Remove existing installation
rm -f ~/.swiftpm/bin/tech-conf-mcp

# Install from source
swift package experimental-install

# Verify installation
~/.swiftpm/bin/tech-conf-mcp --version
```

### 5. Configure Claude Desktop (Optional)

To test with Claude Desktop, update `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "tech-conf": {
      "command": "tech-conf-mcp",
      "args": ["--log-level", "info"],
      "env": {
        "PATH": "$HOME/.swiftpm/bin:/usr/local/bin:/usr/bin:/bin"
      }
    }
  }
}
```

## Development Workflow

### Project Structure

```
tech-conf-mcp/
├── Sources/
│   ├── TechConfCore/         # Domain models & database layer
│   ├── TechConfMCP/          # MCP server implementation
│   └── TechConfSync/         # External data sync (future)
├── Tests/
│   └── TechConfCoreTests/    # Test suite
├── CLAUDE.md                 # Development guidelines
├── USAGE.md                  # User documentation
└── Package.swift             # Swift package manifest
```

### Key Technologies

- **Swift 6.2**: Strict concurrency enforcement with actors
- **GRDB.swift**: Type-safe SQLite database access
- **MCP Swift SDK**: Model Context Protocol implementation
- **Swift Testing**: Modern testing framework (NOT XCTest)

## Testing

### Running Tests

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter ConferenceQueriesTests

# Run with verbose output
swift test --verbose
```

### Writing Tests

Use the **Swift Testing framework** (NOT XCTest):

```swift
import Testing
@testable import TechConfCore

@Suite("ConferenceQueries Tests")
struct ConferenceQueriesTests {

    @Test("List sessions filters by track")
    func listSessionsByTrack() async throws {
        let db = try createTestDatabase()
        let queries = ConferenceQueries(database: db)

        let sessions = try await queries.listSessions(track: "iOS Development")
        #expect(sessions.count > 0)
        #expect(sessions.allSatisfy { $0.track == "iOS Development" })
    }
}
```

**Testing Guidelines**:
- Use `@Suite` for test organization
- Use `@Test` for individual test cases
- Use `#expect()` for assertions (NOT `XCTAssert`)
- Create isolated test databases for each test
- Test async code with `async throws` test methods
- Ensure all tests pass before submitting a pull request

## Code Style

### Swift Format

This project uses Swift's built-in formatter. **DO NOT** create custom formatters.

**Formatting Commands**:

```bash
# Lint the project
swift format lint -s -p -r Sources Tests Package.swift

# Auto-format files
swift format format -p -r -i Sources Tests Package.swift
```

### Style Conventions

- **Indentation**: 2 spaces (not tabs)
- **Line length**: 100 characters maximum
- **Imports**: Sort alphabetically
- **Trailing commas**: Use in multi-line arrays/dictionaries
- **Self**: Use explicit `self.` only when required for disambiguation

### Swift 6 Concurrency

**Actor-based patterns are mandatory**:

```swift
// ✅ Good: Actor isolation for shared state
actor TechConfMCPServer {
    private let server: Server
    private let logger: Logger
}

// ✅ Good: Sendable types
public struct Session: Sendable, Codable { ... }

// ❌ Bad: Non-Sendable types in async contexts
var localCache: [String: Session] = [:]
Task {
    localCache["key"] = session  // Compiler error!
}
```

**Key Requirements**:
- All shared state must be actor-protected
- All MCP tool handlers must be actor-isolated
- Database operations must use `@Sendable` closures
- Models must conform to `Sendable` protocol

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, no logic changes)
- **refactor**: Code refactoring (no feature changes)
- **test**: Adding or updating tests
- **chore**: Maintenance tasks (dependencies, build config)

### Examples

```
feat(mcp): add get_favorites tool for personalized schedules

Implements a new MCP tool that returns user-favorited sessions
across all conferences, ordered by start time.

Closes #42
```

```
fix(queries): correct date parsing for "next week" queries

The DateComponents.parse() method was not correctly handling
"next week" natural language queries. Updated to use proper
calendar arithmetic.

Fixes #38
```

```
docs(contributing): add testing guidelines

Added comprehensive testing guidelines covering Swift Testing
framework usage, test organization, and best practices.
```

## Pull Request Process

### Before Submitting

1. **Ensure all tests pass**:
   ```bash
   swift test
   ```

2. **Format your code**:
   ```bash
   swift format format -p -r -i Sources Tests Package.swift
   ```

3. **Lint your code**:
   ```bash
   swift format lint -s -p -r Sources Tests Package.swift
   ```

4. **Update documentation** if you've changed APIs or added features

5. **Add tests** for new functionality

### Submitting a Pull Request

1. **Fork the repository** and create a branch from `main`:
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make your changes** following the guidelines above

3. **Commit your changes** with clear, conventional commit messages

4. **Push to your fork**:
   ```bash
   git push origin feature/my-new-feature
   ```

5. **Open a Pull Request** against the `main` branch

### Pull Request Template

When opening a PR, include:

- **Description**: What does this PR do?
- **Motivation**: Why is this change needed?
- **Testing**: How was this tested?
- **Checklist**:
  - [ ] Tests pass (`swift test`)
  - [ ] Code is formatted (`swift format`)
  - [ ] Documentation updated
  - [ ] Commit messages follow conventional format

### Review Process

- Maintainers will review your PR within 1-2 weeks
- Address any feedback or requested changes
- Once approved, a maintainer will merge your PR

## Reporting Bugs

### Before Reporting

- **Search existing issues** to avoid duplicates
- **Verify the bug** exists in the latest version
- **Collect information**: version, OS, error messages, logs

### Bug Report Template

```markdown
**Description**
A clear description of the bug.

**To Reproduce**
Steps to reproduce the behavior:
1. Run command '...'
2. Call tool '...'
3. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Environment**
- macOS version:
- Swift version:
- tech-conf-mcp version:

**Logs**
```
Paste relevant logs here
```

**Additional Context**
Any other context about the problem.
```

## Suggesting Enhancements

### Feature Request Template

```markdown
**Problem Statement**
Describe the problem or limitation you're facing.

**Proposed Solution**
Describe your proposed solution or enhancement.

**Alternatives Considered**
Describe alternative solutions you've considered.

**Additional Context**
Any other context, mockups, or examples.
```

## Questions?

- **Documentation**: Check `CLAUDE.md` and `USAGE.md`
- **Issues**: Open a GitHub issue with the `question` label
- **Discussions**: Use GitHub Discussions for general questions

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to Tech Conference MCP Server!**
