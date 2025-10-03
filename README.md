# Tech Conference MCP Server

A Model Context Protocol (MCP) server for managing and querying technical conference data. Built with Swift 6.2, this server provides intelligent access to conference schedules, sessions, speakers, and venues through natural language queries.

## Overview

Tech Conference MCP Server enables AI assistants like Claude to help you navigate technical conferences by providing structured access to:

- **Session Information**: Browse talks, workshops, and keynotes with detailed metadata
- **Speaker Profiles**: Access speaker bios, expertise, and session history
- **Schedule Management**: Query conference schedules with time-aware filtering
- **Venue Navigation**: Find rooms, tracks, and physical locations
- **Smart Search**: Natural language queries across all conference data

## Features

### 6 Core MCP Tools

1. **`list_sessions`** - Browse all conference sessions with optional filtering
2. **`search_sessions`** - Find sessions using natural language queries
3. **`get_speaker`** - Retrieve detailed speaker information and their sessions
4. **`get_schedule`** - Query schedule for specific days or time ranges
5. **`find_room`** - Locate rooms and check their schedules
6. **`get_session_details`** - Get comprehensive details about a specific session

### Sample Queries

```
"Show me all Swift talks tomorrow"
"Who is speaking about concurrency?"
"What's in the main hall at 2pm?"
"Find sessions about server-side Swift"
"Show me Sarah's talk details"
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
git clone https://github.com/yourusername/tech-conf-mcp.git
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

## Sample Data

The server includes sample data from **ServerSide.swift 2025** conference:

- **50+ sessions** covering Swift on the server, iOS, and tooling
- **27+ speakers** including Apple engineers, framework authors, and production experts
- **Multiple tracks** across 3 days (Oct 15-17, 2025)
- **6 venues** with detailed room information

This sample data demonstrates the server's capabilities and can be replaced with your own conference data.

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
