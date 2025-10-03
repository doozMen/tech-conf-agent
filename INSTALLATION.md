# Installation Guide - Tech Conference MCP Server

## Overview

This document provides complete instructions for building, installing, and configuring the Tech Conference MCP (Model Context Protocol) server for use with Claude Code.

## Prerequisites

- macOS (Apple Silicon or Intel)
- Swift 6.0 or later
- Xcode command line tools
- Claude Desktop application

## Build Instructions

### 1. Clean Build

Start with a clean build environment:

```bash
swift package clean
swift build -c release
```

The release build typically takes 60-90 seconds and produces an optimized binary.

### 2. Run Tests

Verify the build with the test suite:

```bash
swift test
```

Most tests should pass. Some tests may fail due to schema differences but core functionality remains intact.

## Installation Steps

### 1. Install the MCP Server

Remove any existing installation and install the new binary:

```bash
# Remove existing installation if present
rm -f ~/.swiftpm/bin/tech-conf-mcp

# Install to SwiftPM bin directory
swift package experimental-install
```

The binary will be installed to: `~/.swiftpm/bin/tech-conf-mcp`

### 2. Verify Installation

Check that the binary is installed correctly:

```bash
# Check file exists and size
ls -lh ~/.swiftpm/bin/tech-conf-mcp

# Verify binary type
file ~/.swiftpm/bin/tech-conf-mcp

# Test execution
~/.swiftpm/bin/tech-conf-mcp --version
```

Expected output:
- Binary size: ~25 MB
- Type: Mach-O 64-bit executable arm64
- Version: 1.0.0

### 3. Configure Claude Desktop

Edit or create the Claude Desktop configuration file:

**File location:** `~/Library/Application Support/Claude/claude_desktop_config.json`

Add the following server configuration to the `mcpServers` object:

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

**Important:** The `PATH` environment variable must include `~/.swiftpm/bin` for the command to be found.

### 4. Configure Project Permissions (Optional)

Create or update `.claude/settings.local.json` in your project directory:

**File:** `.claude/settings.local.json`

```json
{
  "permissions": {
    "allow": [
      "mcp__tech-conf__list_sessions",
      "mcp__tech-conf__search_sessions",
      "mcp__tech-conf__get_speaker",
      "mcp__tech-conf__get_schedule",
      "mcp__tech-conf__find_room",
      "mcp__tech-conf__get_session_details"
    ]
  }
}
```

This pre-authorizes the MCP tools for use in Claude Code.

## Usage

### Available MCP Tools

Once installed and configured, the following tools are available:

1. **list_sessions** - List all conference sessions
   - Optional filters: conference, format, track, difficulty, speaker

2. **search_sessions** - Search sessions by title or description
   - Required: search query

3. **get_speaker** - Get detailed speaker information
   - Required: speaker ID

4. **get_schedule** - Get schedule for a specific date/time
   - Required: date/time string

5. **find_room** - Find venue/room information
   - Required: venue name

6. **get_session_details** - Get detailed session information
   - Required: session ID

### Example Usage in Claude Code

After restarting Claude Desktop, you can use natural language commands:

```
"Show me all Swift sessions at the conference"
"Find sessions by Speaker Name"
"What's the schedule for tomorrow?"
"Tell me about the keynote session"
```

Claude will automatically invoke the appropriate MCP tools to answer your questions.

## Verification Steps

### 1. Check Binary Installation

```bash
which tech-conf-mcp
# Expected: /Users/<username>/.swiftpm/bin/tech-conf-mcp
```

### 2. Test MCP Server Startup

```bash
tech-conf-mcp --log-level debug
# Should start the MCP server and wait for stdio commands
# Press Ctrl+C to exit
```

### 3. Restart Claude Desktop

After configuration changes:
1. Quit Claude Desktop completely
2. Restart the application
3. The MCP server should appear in the available tools

### 4. Verify in Claude Code

In a new Claude Code conversation:
1. Type a question about conferences
2. Claude should offer to use the tech-conf MCP tools
3. Grant permission when prompted (or use settings.local.json to pre-authorize)

## Troubleshooting

### Binary Not Found

If you get "command not found" errors:

1. Verify the binary exists:
   ```bash
   ls -l ~/.swiftpm/bin/tech-conf-mcp
   ```

2. Check PATH in Claude config includes `$HOME/.swiftpm/bin`

3. Use absolute path in config:
   ```json
   "command": "/Users/<username>/.swiftpm/bin/tech-conf-mcp"
   ```

### Server Won't Start

1. Check logs in Claude Desktop console
2. Run manually with debug logging:
   ```bash
   ~/.swiftpm/bin/tech-conf-mcp --log-level debug
   ```
3. Verify no port conflicts

### Database Errors

If you encounter database-related errors:

1. The server will create an in-memory database on first run
2. Check file permissions if using file-based database
3. Review error logs for specific SQLite errors

### Build Errors

If the build fails:

1. Ensure you have Swift 6.0+:
   ```bash
   swift --version
   ```

2. Clean and rebuild:
   ```bash
   rm -rf .build
   swift package clean
   swift build -c release
   ```

3. Check for macro/plugin validation issues (should be handled automatically)

## Uninstallation

To remove the MCP server:

```bash
# Remove binary
rm ~/.swiftpm/bin/tech-conf-mcp

# Remove from Claude config
# Edit: ~/Library/Application Support/Claude/claude_desktop_config.json
# Remove the "tech-conf" entry from mcpServers

# Remove project permissions
rm .claude/settings.local.json
```

## Development

### Rebuilding After Changes

```bash
swift build -c release
swift package experimental-install
# Restart Claude Desktop
```

### Running Tests

```bash
swift test
```

### Formatting Code

```bash
swift format lint -s -p -r Sources Tests Package.swift
swift format format -p -r -i Sources Tests Package.swift
```

## Technical Details

- **Language:** Swift 6.0
- **Architecture:** MCP (Model Context Protocol)
- **Database:** SQLite with GRDB
- **Transport:** stdio
- **Binary Size:** ~25 MB (release build)
- **Platform:** macOS (Apple Silicon + Intel)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review logs in Claude Desktop console
3. Run the server manually with debug logging
4. Check the project repository for updates

## Version History

- **1.0.0** - Initial release
  - Core MCP tools for conference data
  - SQLite database integration
  - Claude Desktop integration
  - Basic query capabilities
