# ServerSide.swift 2025 Conference Navigator

A Model Context Protocol (MCP) server built specifically for **ServerSide.swift 2025 London** (October 2-3, 2025). Navigate the conference with AI-powered queries about sessions, speakers, and schedules through Claude Desktop.

Built with Swift 6.2 and actor-based concurrency, this MCP server provides comprehensive access to the ServerSide.swift conference data including 27+ speakers, session schedules, and venue information.

## Overview

This MCP server is tailored specifically for **ServerSide.swift 2025 London**, featuring:

- **27+ Speaker Profiles**: Apple Swift Server team members (Franz Busch, George Barnett, Ben Cohen), framework creators (Adam Fowler - Hummingbird, Joannis Orlandos - MongoKitten), and production experts
- **Complete Conference Schedule**: All sessions from October 2-3, 2025 with tracks, difficulty levels, and formats
- **Natural Language Queries**: Ask about sessions, speakers, and topics in plain English
- **Real Conference Data**: Authentic speaker bios, GitHub profiles, expertise areas, and session topics

### Use Cases

- **Conference Attendees**: Find sessions matching your interests, discover speakers, plan your schedule
- **Speaker Networking**: Learn about speakers' backgrounds, expertise, and projects before the conference
- **Session Discovery**: Search by topic (Swift 6, concurrency, Vapor, Hummingbird, AWS Lambda, etc.)
- **Schedule Planning**: Query sessions by day, time, track, or difficulty level

### Could This Work for Other Conferences?

While this MCP server is specifically built for ServerSide.swift 2025, the architecture could be adapted for other technical conferences. The database schema and MCP tools are general enough to support any conference with sessions, speakers, and schedules. You would need to:

1. Replace the sample data in `Resources/Conferences/` with your conference data
2. Update speaker profiles, session schedules, and venue information
3. Optionally customize the database schema for conference-specific needs

The Swift 6.2 codebase, actor-based concurrency, and MCP protocol implementation are conference-agnostic.

## Features

### 6 Core MCP Tools

1. **`list_sessions`** - Browse all conference sessions with optional filtering
2. **`search_sessions`** - Find sessions using natural language queries
3. **`get_speaker`** - Retrieve detailed speaker information and their sessions
4. **`get_schedule`** - Query schedule for specific days or time ranges
5. **`find_room`** - Locate rooms and check their schedules
6. **`get_session_details`** - Get comprehensive details about a specific session

### Sample Queries for ServerSide.swift 2025

```
"Show me all sessions on October 2nd"
"Who is Adam Fowler and what is he talking about?"
"Find all sessions about Vapor and Hummingbird"
"What Swift 6 concurrency sessions are there?"
"Show me speakers from the Apple Swift Server team"
"Which sessions cover AWS Lambda with Swift?"
"Tell me about Joannis Orlandos' MongoKitten talk"
```

## Architecture

### Technology Stack

- **Swift 6.2**: Modern Swift with strict concurrency checking
- **MCP Swift SDK**: Official Model Context Protocol implementation
- **SharingGRDB**: Type-safe SQLite database layer with observable queries
- **Actor-based Concurrency**: Thread-safe data access

### Project Structure

```
tech-conf-mcp/
├── Sources/
│   ├── TechConfCore/          # Domain models and database layer
│   │   ├── Models/             # Session, Speaker, Room entities
│   │   ├── Database/           # SQLite schema and migrations
│   │   └── Queries/            # Type-safe query methods
│   │
│   ├── TechConfMCP/           # MCP server implementation
│   │   ├── Server.swift        # Main MCP server with tool handlers
│   │   ├── Tools/              # Individual tool implementations
│   │   └── ValueExtensions/    # MCP value serialization
│   │
│   └── tech-conf-mcp/         # Executable entry point
│       └── main.swift          # CLI and server initialization
│
├── Data/
│   ├── conferences.sqlite      # SQLite database
│   └── migrations/             # Database migration scripts
│
└── Tests/
    └── TechConfTests/          # Swift Testing test suite
```

### Database Schema

The server uses SQLite with the following core tables:

- **`sessions`** - Conference talks with title, description, time, track
- **`speakers`** - Speaker profiles with bio, expertise, contact info
- **`rooms`** - Venue locations with capacity and equipment details
- **`session_speakers`** - Many-to-many relationship between sessions and speakers
- **`tags`** - Categorical tags for filtering (Swift, iOS, Server, etc.)

## Installation

### Requirements

- **macOS 15.0+** (Sequoia or later)
- **Swift 6.2+** (included with Xcode 16.2+)
- **Claude Desktop** (for MCP integration)

### Install via Swift Package Manager

```bash
# Clone the repository
git clone https://github.com/doozMen/tech-conf-agent.git
cd tech-conf-mcp

# Install the executable
swift package experimental-install

# Verify installation
~/.swiftpm/bin/tech-conf-mcp --version
```

The executable will be installed to `~/.swiftpm/bin/tech-conf-mcp`.

### Configure Claude Desktop

Add to your Claude Desktop configuration file (`~/Library/Application Support/Claude/claude_desktop_config.json`):

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

**Important**: The `PATH` environment variable must include `~/.swiftpm/bin` for Claude Desktop to find the installed executable.

### Restart Claude Desktop

After updating the configuration:

1. Quit Claude Desktop completely
2. Relaunch Claude Desktop
3. Verify the MCP server is connected (look for "tech-conf" in available tools)

## Usage

### Example Conversations

**Finding Sessions**
```
You: Show me all sessions about Swift concurrency tomorrow
Claude: [Uses search_sessions tool]
```

**Speaker Information**
```
You: Who is John Sundell and what is he talking about?
Claude: [Uses get_speaker tool]
```

**Schedule Queries**
```
You: What's happening in Hall A between 2pm and 4pm?
Claude: [Uses get_schedule and find_room tools]
```

**Session Details**
```
You: Tell me more about the "Modern Swift Concurrency" talk
Claude: [Uses get_session_details tool]
```

### Natural Language Support

The MCP server understands various date/time formats:

- Relative: "today", "tomorrow", "this afternoon"
- Absolute: "October 15", "Oct 15 2025", "2025-10-15"
- Time ranges: "2pm-4pm", "14:00-16:00", "afternoon"
- Day parts: "morning", "afternoon", "evening"

## Speaker Discovery

The MCP server includes comprehensive speaker profiles from **ServerSide.swift 2025 London**:

- **27+ speakers** with full bios, expertise areas, and professional backgrounds
- **Apple Swift Server team members**: Franz Busch, George Barnett, Honza Dvorsky, Ben Cohen, Si Beaumont, Eric Ernst, Agam Dua
- **Framework creators**: Adam Fowler (Hummingbird, Soto), Joannis Orlandos (MongoKitten)
- **Production experts**: Ben Rosen (SongShift), Mikaela Caron (Vapor backends), Daniel Jilg (TelemetryDeck)
- **Social links**: GitHub, Twitter, LinkedIn, personal websites

### Example Speaker Queries

```
"Who is Adam Fowler and what is he talking about?"
→ Returns: Senior Apple engineer, Hummingbird maintainer, speaking on Valkey-swift with type-safe Redis

"Show me all sessions by Mikaela Caron"
→ Returns: "Building Fruitful" - Vapor 4 backend with PostgreSQL, S3, Redis, JWT auth

"Find speakers working on Swift concurrency"
→ Returns: Matt Massicotte (Swift 6 patterns), Mikaela Caron (strict concurrency in Vapor)
```

**Full speaker documentation**: See [docs/Speakers | ServerSide.md](docs/Speakers%20|%20ServerSide.md) for complete profiles with expertise, social links, and session topics.

## Conference Data

The server contains **real data from ServerSide.swift 2025 London**:

- **27+ Real Speakers**: Actual speaker profiles from the conference website with verified bios, GitHub profiles, and expertise areas
- **Complete Sessions**: All talks, workshops, and sessions from October 2-3, 2025
- **Conference Venue**: London, UK location details
- **Session Tracks**: Server-Side Swift, Vapor Framework, Hummingbird, SwiftNIO, Testing & Quality, Deployment & DevOps, Swift 6 & Concurrency

**Conference Website**: [serversideswift.info](https://www.serversideswift.info/)

This is production conference data, not sample/demo data. The database is pre-populated with the actual ServerSide.swift 2025 conference schedule and speaker information.

## Development

### Building from Source

```bash
# Debug build
swift build

# Release build  
swift build -c release

# Run locally
swift run tech-conf-mcp
```

### Running Tests

```bash
# Run all tests with Swift Testing
swift test

# Run with verbose output
swift test --verbose

# Run specific test suite
swift test --filter TechConfCoreTests
```

### Database Management

```bash
# View database schema
sqlite3 Data/conferences.sqlite ".schema"

# Query sessions
sqlite3 Data/conferences.sqlite "SELECT title, startTime FROM sessions;"

# Backup database
cp Data/conferences.sqlite Data/conferences.backup.sqlite
```

### Automation Scripts

The `Scripts/` directory contains automation tools for development and release:

#### Release Script
Install the MCP server to `~/.swiftpm/bin` and generate Claude Desktop configuration:

```bash
./Scripts/release.sh
```

This will:
1. Remove any existing installation
2. Build and install the latest version
3. Verify the installation
4. Generate MCP configuration JSON
5. Print next steps for Claude Desktop setup

#### JSON-RPC Testing
Test the MCP server using `swift run` (tests current source code, NOT installed binary):

```bash
./Scripts/test-mcp-jsonrpc.sh
```

⚠️ **Critical**: This script uses `xcrun swift run tech-conf-mcp` to test the **latest source code**. This ensures you're always testing your current changes, not an old installed binary.

Test output includes:
- ✅ Passed tests (green)
- ❌ Failed tests (red)
- JSON-RPC responses for each tool
- Final summary with pass/fail count

#### Version Management
Bump version across all files and update changelog:

```bash
./Scripts/bump-version.sh 1.1.0
```

This will:
1. Extract current version from source
2. Update `TechConfMCP.swift` version
3. Update `CLAUDE.md` and `README.md` references
4. Add new section to `CHANGELOG.md`
5. Print git commit commands

### Testing Patterns

**Development Testing** (current source code):
```bash
./Scripts/test-mcp-jsonrpc.sh  # Tests with `swift run`
```

**Production Verification** (installed binary):
```bash
./test-mcp.py  # Tests ~/.swiftpm/bin/tech-conf-mcp
```

Use `test-mcp-jsonrpc.sh` during development to test changes before installation.

## Credits

This project was inspired by and learned from:

- **[TimeStory MCP](https://github.com/stijnwillems/timestory-mcp)** - Reference implementation for MCP server patterns in Swift
- **[MCP Swift SDK](https://github.com/modelcontextprotocol/swift-sdk)** - Official Model Context Protocol SDK
- **[SharingGRDB](https://github.com/shareup/sharing-grdb)** - Type-safe SQLite wrapper with observable queries

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues, questions, or feature requests, please open an issue on GitHub.
