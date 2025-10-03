# Tech Conference MCP Server - User Guide

**Version**: 1.0.0  
**Audience**: Developers and AI users integrating conference data with Claude Desktop

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Claude Desktop Configuration](#claude-desktop-configuration)
3. [Tool Reference](#tool-reference)
4. [Natural Language Examples](#natural-language-examples)
5. [Troubleshooting](#troubleshooting)
6. [Advanced Usage](#advanced-usage)

---

## Quick Start

### Requirements

- **macOS 15.0+** (Sequoia or later)
- **Swift 6.2+** (included with Xcode 16.2+)
- **Claude Desktop** for MCP integration

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/tech-conf-mcp.git
cd tech-conf-mcp

# Build the project
swift build -c release

# Install the executable (removes existing version first)
rm -f ~/.swiftpm/bin/tech-conf-mcp
swift package experimental-install

# Verify installation
~/.swiftpm/bin/tech-conf-mcp --version
```

The executable will be installed to `~/.swiftpm/bin/tech-conf-mcp`.

### Database Setup

By default, the server creates a database at `~/.tech-conf-mcp/conferences.db`. You can specify a custom location using the `--db-path` option:

```bash
tech-conf-mcp --db-path /path/to/custom/database.db
```

---

## Claude Desktop Configuration

### Configuration File Location

Add the MCP server to your Claude Desktop configuration file:

- **Path**: `~/Library/Application Support/Claude/claude_desktop_config.json`

### Configuration Example

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

**Important Configuration Notes:**

1. **PATH Environment Variable**: Must include `$HOME/.swiftpm/bin` for Claude Desktop to find the installed executable
2. **Log Levels**: Choose from `debug`, `info`, `warning`, or `error` (default: `info`)
3. **Custom Database Path** (optional):
   ```json
   {
     "mcpServers": {
       "tech-conf": {
         "command": "tech-conf-mcp",
         "args": [
           "--log-level", "info",
           "--db-path", "/path/to/conferences.db"
         ],
         "env": {
           "PATH": "$HOME/.swiftpm/bin:/usr/local/bin:/usr/bin:/bin"
         }
       }
     }
   }
   ```

### Activating the Configuration

1. **Save** the configuration file
2. **Quit** Claude Desktop completely (Cmd+Q)
3. **Relaunch** Claude Desktop
4. **Verify** connection by checking available tools in the MCP tools panel

---

## Tool Reference

The Tech Conference MCP server provides **6 core tools** for querying conference data:

### 1. `list_sessions`

**Purpose**: Browse conference sessions with optional filtering

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `track` | string | No | Filter by track name (e.g., "iOS Development", "Backend") |
| `day` | string | No | Filter by date (YYYY-MM-DD format or natural language like "today") |
| `speaker` | string | No | Filter by speaker name (partial match) |
| `difficulty` | string | No | Filter by difficulty: `beginner`, `intermediate`, `advanced`, `all` |
| `format` | string | No | Filter by format: `talk`, `workshop`, `panel`, `keynote`, `lightning` |
| `isFavorited` | boolean | No | Show only favorited sessions |
| `isUpcoming` | boolean | No | Show only upcoming sessions |

**Example Queries**:
- "Show me all sessions"
- "List sessions about Swift"
- "What workshops are available tomorrow?"
- "Show me beginner-level sessions"
- "List all keynote sessions"

**Example Response**:
```json
[
  {
    "id": "uuid-here",
    "title": "Swift Concurrency Deep Dive",
    "description": "Learn about Swift's modern concurrency features...",
    "startTime": "2025-10-15T14:00:00Z",
    "endTime": "2025-10-15T15:30:00Z",
    "track": "Server-Side Swift",
    "format": "talk",
    "difficultyLevel": "intermediate",
    "speakerName": "Jane Developer",
    "venueName": "Main Hall A",
    "capacity": 200,
    "tags": ["swift", "concurrency", "async-await"]
  }
]
```

---

### 2. `search_sessions`

**Purpose**: Full-text search across session titles, descriptions, and tags

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | **Yes** | Search query text |

**Example Queries**:
- "Find sessions about SwiftUI"
- "Search for talks on performance optimization"
- "Show me sessions mentioning Vapor"
- "Find anything related to testing"

**Behavior**:
- Searches across title, description, track, speaker name, and tags
- Returns results sorted by relevance (exact title matches first)
- Automatically limits to top 20 most relevant results

**Example Response**:
```json
[
  {
    "id": "uuid-here",
    "title": "SwiftUI Performance Optimization",
    "description": "Deep dive into SwiftUI rendering performance...",
    "relevanceScore": 95,
    "track": "iOS Development",
    "startTime": "2025-10-15T10:00:00Z"
  }
]
```

---

### 3. `get_speaker`

**Purpose**: Retrieve detailed information about a specific speaker

**Parameters** (at least one required):
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `speakerId` | string | No | Speaker UUID |
| `speakerName` | string | No | Speaker name (partial match) |

**Example Queries**:
- "Who is Jane Developer?"
- "Tell me about the speaker John Sundell"
- "Get speaker details for UUID xxx"
- "What sessions is Sarah giving?"

**Example Response**:
```json
{
  "id": "uuid-here",
  "name": "Jane Developer",
  "bio": "Senior Swift Engineer with 10+ years of experience...",
  "title": "Senior iOS Engineer",
  "company": "Apple",
  "twitter": "@janedeveloper",
  "github": "https://github.com/janedeveloper",
  "expertise": ["Swift Concurrency", "Server-Side Swift", "iOS Architecture"],
  "sessions": [
    {
      "id": "session-uuid",
      "title": "Swift Concurrency Deep Dive",
      "startTime": "2025-10-15T14:00:00Z",
      "track": "iOS Development"
    }
  ],
  "stats": {
    "totalSessions": 2,
    "yearsExperience": 10,
    "conferencesSpeaker": 25
  }
}
```

---

### 4. `get_schedule`

**Purpose**: Get conference schedule for a specific time range

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `date` | string | No | Date (YYYY-MM-DD or "today", "tomorrow") |
| `startTime` | string | No | Start time (HH:MM format, e.g., "14:00") |
| `endTime` | string | No | End time (HH:MM format, e.g., "16:00") |

**Example Queries**:
- "What's on the schedule today?"
- "Show me tomorrow's schedule"
- "What sessions are happening between 2pm and 4pm?"
- "Get the schedule for October 15, 2025"

**Behavior**:
- If no date provided, defaults to today
- If no time range provided, returns full day schedule
- Returns sessions sorted chronologically

**Example Response**:
```json
{
  "date": "2025-10-15",
  "dateDescription": "Today",
  "startTime": "2025-10-15T00:00:00Z",
  "endTime": "2025-10-15T23:59:59Z",
  "totalSessions": 8,
  "sessions": [
    {
      "id": "uuid-here",
      "title": "Opening Keynote",
      "startTime": "2025-10-15T09:00:00Z",
      "endTime": "2025-10-15T10:00:00Z",
      "room": "Main Hall",
      "track": "Keynote"
    }
  ]
}
```

---

### 5. `find_room`

**Purpose**: Find venue information and current/upcoming sessions

**Parameters** (at least one required):
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `roomName` | string | No | Room or venue name (partial match) |
| `sessionId` | string | No | Get room for specific session UUID |

**Example Queries**:
- "Where is the Main Hall?"
- "Find the room for session UUID xxx"
- "Show me details about Workshop Room B"
- "What's the capacity of Hall A?"

**Example Response**:
```json
{
  "id": "venue-uuid",
  "name": "Main Hall A",
  "building": "Convention Center",
  "floor": "2",
  "capacity": 200,
  "accessibility": {
    "wheelchairAccessible": true,
    "hearingLoop": true,
    "signLanguageInterpreter": true
  },
  "equipment": ["4K projector", "wireless microphone", "recording equipment"],
  "directions": "Take elevator to 2nd floor, turn right",
  "currentSession": {
    "id": "session-uuid",
    "title": "Swift Concurrency Deep Dive",
    "status": "ongoing",
    "speakers": [{"name": "Dr. Sarah Johnson", "company": "Apple"}]
  },
  "upcomingSessions": [
    {
      "id": "session-uuid",
      "title": "Building Scalable SwiftUI Apps",
      "startTime": "2025-10-15T16:00:00Z"
    }
  ]
}
```

---

### 6. `get_session_details`

**Purpose**: Get comprehensive details about a specific session

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `sessionId` | string | **Yes** | Session UUID |

**Example Queries**:
- "Tell me more about session UUID xxx"
- "Get full details for the Swift Concurrency talk"
- "Show me complete information for this session"

**Example Response**:
```json
{
  "id": "session-uuid",
  "title": "Swift Concurrency: Building Efficient Async Systems",
  "description": "This comprehensive session explores...",
  "abstract": "Swift's concurrency model represents a paradigm shift...",
  "format": "talk",
  "difficultyLevel": "advanced",
  "track": "iOS Development",
  "tags": ["Swift", "Concurrency", "Async/Await", "Actors"],
  "startTime": "2025-10-15T14:00:00Z",
  "endTime": "2025-10-15T15:30:00Z",
  "durationMinutes": 90,
  "speakers": [
    {
      "id": "speaker-uuid",
      "name": "Dr. Sarah Johnson",
      "title": "Senior iOS Engineer",
      "company": "Apple",
      "bio": "Sarah has been working on the Swift language team...",
      "expertise": ["Swift Concurrency", "iOS Development"]
    }
  ],
  "venue": {
    "name": "Main Hall A",
    "capacity": 200,
    "accessibility": {"wheelchairAccessible": true}
  },
  "isRecorded": true,
  "recordingURL": "https://conference.com/recordings/swift-concurrency-2025",
  "slidesURL": "https://conference.com/slides/swift-concurrency-2025.pdf",
  "relatedSessions": [
    {
      "id": "related-uuid",
      "title": "Actor Isolation Patterns",
      "similarity": 0.95
    }
  ],
  "prerequisites": [
    "Basic understanding of async/await",
    "Familiarity with Swift 5.5+"
  ],
  "learningOutcomes": [
    "Master structured concurrency patterns",
    "Implement thread-safe code with actors"
  ]
}
```

---

## Natural Language Examples

The MCP server understands natural language queries. Here are common conversation patterns:

### Browsing Sessions

**User**: "Show me all SwiftUI sessions"  
**Claude**: *Uses `search_sessions` with query="SwiftUI"*

**User**: "What talks are happening tomorrow afternoon?"  
**Claude**: *Uses `list_sessions` with day="tomorrow" + filters for afternoon time*

**User**: "Find beginner workshops about testing"  
**Claude**: *Uses `list_sessions` with difficulty="beginner", format="workshop" + search for "testing"*

### Speaker Information

**User**: "Who is speaking about concurrency?"
**Claude**: *Uses `search_sessions` with query="concurrency" then extracts speaker info*

**User**: "Tell me about John Sundell"
**Claude**: *Uses `get_speaker` with speakerName="John Sundell"*

**User**: "What sessions is Sarah giving?"
**Claude**: *Uses `get_speaker` to find Sarah, then lists her sessions*

---

## Speaker Query Examples

The MCP server includes comprehensive speaker data from **ServerSide.swift 2025 London** with 27+ speakers. Here are real-world query examples:

### Query by Name

**Find specific speaker**:
```
get_speaker(speakerName="Adam Fowler")

Returns:
- Name: Adam Fowler
- Title: Senior Software Engineer at Apple
- Bio: Maintainer of Hummingbird framework and Soto AWS SDK
- Expertise: Hummingbird, AWS, Cloud Infrastructure, Serverless, Redis/Valkey
- GitHub: https://github.com/adam-fowler
- Twitter: @adamfowler
- Sessions: "Valkey-swift: Type-Safe Redis Client"
```

**Partial name matching**:
```
get_speaker(speakerName="Mikaela")

Returns: Mikaela Caron
- Independent iOS Engineer, Icy App Studio LLC
- Expertise: Vapor, PostgreSQL, AWS S3, Redis, JWT Authentication, Swift 6 Concurrency
- Session: "Building Fruitful: A Real Conference Networking App Backend"
```

### Query by Expertise

**Find Swift concurrency experts**:
```
search_sessions(query="Swift 6 concurrency")

Returns sessions by:
- Matt Massicotte: "Swift 6 Concurrency for Server Applications"
- Mikaela Caron: Backend with Swift 6 strict concurrency
```

**Find AWS specialists**:
```
search_sessions(query="AWS")

Returns sessions by:
- Ben Rosen: "SongShift's Production Swift Lambda Architecture"
- Mona Dierickx: "Swift Bedrock Library: Idiomatic AWS Integration"
- Adam Fowler: Soto AWS SDK expertise
```

**Find framework creators**:
```
get_speaker(speakerName="Joannis Orlandos")

Returns:
- Founder & Lead Developer: MongoKitten & Vapor
- Expertise: MongoDB, Databases, Performance, SwiftNIO, Zero-Copy Networking
- Session: "Zero-Copy Networking with Span"
```

### Query by Company

**Find Apple engineers**:
```
list_sessions(speaker="Apple")

Returns sessions by:
- Adam Fowler (Senior Software Engineer)
- Franz Busch (SwiftNIO team)
- George Barnett (gRPC Swift)
- Honza Dvorsky (Swift Server Ecosystem)
- Ben Cohen (Swift Core Team Manager)
- Si Beaumont (Server Infrastructure)
- Eric Ernst (Engineering Leader)
- Agam Dua (Education team)
```

### Production Experience

**Find real-world production speakers**:
```
get_speaker(speakerName="Ben Rosen")

Returns:
- Founder of SongShift
- Production Swift Lambda architecture expert
- Session: Complete serverless evolution from Docker/Node.js to Swift Lambda
```

```
get_speaker(speakerName="Daniel Jilg")

Returns:
- CTO of TelemetryDeck
- Expertise: Analytics, Data Processing, Privacy, Production Swift Backends
- Building privacy-focused analytics with server-side Swift
```

### Social Links Discovery

Every speaker profile includes social links for networking:

```
get_speaker(speakerName="Matt Massicotte")

Returns:
- GitHub: https://github.com/mattmassicotte
- Website: https://massicotte.org
- Expertise: Swift Concurrency, Swift 6, Actor Isolation, Server-Side Patterns
```

### Conference Role Filtering

**Workshop instructors**:
- Daniel Steinberg (MC & Workshop)
- Matt Massicotte (Swift 6 Concurrency)
- Frank Lefebvre (Training)
- Agam Dua (Apple Education team)

**Framework maintainers**:
- Adam Fowler (Hummingbird, Soto)
- Joannis Orlandos (MongoKitten, Vapor core team)

**See full speaker list**: [docs/Speakers | ServerSide.md](docs/Speakers%20|%20ServerSide.md)

### Schedule Queries

**User**: "What's happening at 2pm tomorrow?"  
**Claude**: *Uses `get_schedule` with date="tomorrow", startTime="14:00", endTime="15:00"*

**User**: "Show me today's schedule"  
**Claude**: *Uses `get_schedule` with date="today"*

**User**: "What sessions are in the Main Hall this afternoon?"  
**Claude**: *Uses `find_room` with roomName="Main Hall" + filters for afternoon*

### Venue Navigation

**User**: "Where is the Vapor workshop?"  
**Claude**: *Uses `search_sessions` to find Vapor workshop, then `find_room` with sessionId*

**User**: "Is the Main Hall wheelchair accessible?"  
**Claude**: *Uses `find_room` with roomName="Main Hall" and shows accessibility info*

**User**: "What's currently happening in Room 201?"  
**Claude**: *Uses `find_room` with roomName="Room 201" to show current session*

### Date/Time Formats Supported

The server understands various date/time formats:

**Relative Dates**:
- "today", "tomorrow", "yesterday"
- "this week", "next week", "last week"
- "monday", "next tuesday", "this friday"

**Absolute Dates**:
- ISO 8601: "2025-10-15", "2025-10-15T14:30:00Z"
- Natural: "October 15", "Oct 15 2025"

**Time Formats**:
- 24-hour: "14:00", "16:30"
- 12-hour: "2pm", "4:30 PM"
- Time ranges: "2pm-4pm", "14:00-16:00"

---

## Troubleshooting

### Server Not Showing Up in Claude Desktop

**Symptom**: MCP server not appearing in Claude Desktop tools panel

**Solutions**:
1. **Verify PATH**: Ensure `~/.swiftpm/bin` is in the PATH environment variable in config
2. **Check Installation**: Run `~/.swiftpm/bin/tech-conf-mcp --version` in terminal
3. **Restart Claude**: Quit Claude Desktop completely (Cmd+Q) and relaunch
4. **Check Logs**: Look for errors in Claude Desktop logs (`~/Library/Logs/Claude/mcp*.log`)

### Database Initialization Errors

**Symptom**: Server fails to start with database errors

**Solutions**:
1. **Check Permissions**: Ensure `~/.tech-conf-mcp/` directory is writable
   ```bash
   mkdir -p ~/.tech-conf-mcp
   chmod 755 ~/.tech-conf-mcp
   ```
2. **Reset Database**: Delete and recreate database
   ```bash
   rm -rf ~/.tech-conf-mcp/conferences.db
   # Restart server to recreate
   ```
3. **Custom Path**: Use `--db-path` to specify alternative location

### Search Returns No Results

**Symptom**: Search queries return empty results

**Solutions**:
1. **Check Database**: Verify database has sample data loaded
2. **Broaden Query**: Use more general search terms
3. **Check Spelling**: Verify query spelling matches session content
4. **Use Filters**: Try `list_sessions` with filters instead of `search_sessions`

### Date Parsing Failures

**Symptom**: "Invalid date format" error

**Solutions**:
1. **Use ISO Format**: Stick to YYYY-MM-DD format (e.g., "2025-10-15")
2. **Check Natural Language**: Supported terms: today, tomorrow, monday, etc.
3. **Verify Timezone**: Ensure dates align with conference timezone

### Performance Issues

**Symptom**: Slow query responses

**Solutions**:
1. **Limit Results**: Use specific filters to reduce result set
2. **Use Pagination**: Request smaller chunks of data
3. **Vacuum Database**: Run maintenance (requires direct database access)
   ```bash
   sqlite3 ~/.tech-conf-mcp/conferences.db "VACUUM"
   ```

### Installation Fails

**Symptom**: `swift package experimental-install` fails

**Solutions**:
1. **Update Swift**: Ensure Swift 6.2+ is installed
   ```bash
   swift --version  # Should show 6.2 or later
   ```
2. **Clean Build**: Remove build artifacts and retry
   ```bash
   swift package clean
   swift build -c release
   swift package experimental-install
   ```
3. **Manual Installation**: Copy binary manually
   ```bash
   cp .build/release/tech-conf-mcp ~/.swiftpm/bin/
   ```

---

## Advanced Usage

### Combining Filters

You can combine multiple filters for precise queries:

```
User: "Show me advanced Swift talks tomorrow that are recorded"

Claude uses:
{
  "tool": "list_sessions",
  "arguments": {
    "day": "tomorrow",
    "difficulty": "advanced",
    "isRecorded": true
  }
} + search for "Swift"
```

### Pagination Strategies

For large result sets, request data in chunks:

```
User: "Show me the first 10 sessions, then the next 10"

Claude uses sequential calls with appropriate filters
```

### Cross-Tool Queries

Combine tools for complex queries:

1. **Find sessions → Get speaker details**:
   - Search sessions with `search_sessions`
   - Extract speaker IDs
   - Call `get_speaker` for each unique speaker

2. **Schedule → Room details**:
   - Get schedule with `get_schedule`
   - Extract venue IDs
   - Call `find_room` for venue details

3. **Speaker → All sessions → Venues**:
   - Get speaker with `get_speaker`
   - Extract session IDs
   - Get session details with `get_session_details`
   - Extract venue info

### Custom Database Path

For multi-conference setups:

```json
{
  "mcpServers": {
    "serverside-swift": {
      "command": "tech-conf-mcp",
      "args": ["--db-path", "~/conferences/serverside-2025.db"],
      "env": {"PATH": "$HOME/.swiftpm/bin:/usr/local/bin:/usr/bin:/bin"}
    },
    "ios-conf": {
      "command": "tech-conf-mcp",
      "args": ["--db-path", "~/conferences/ios-conf-2025.db"],
      "env": {"PATH": "$HOME/.swiftpm/bin:/usr/local/bin:/usr/bin:/bin"}
    }
  }
}
```

### Debug Mode

Enable verbose logging for troubleshooting:

```json
{
  "mcpServers": {
    "tech-conf": {
      "command": "tech-conf-mcp",
      "args": ["--log-level", "debug"],
      "env": {"PATH": "$HOME/.swiftpm/bin:/usr/local/bin:/usr/bin:/bin"}
    }
  }
}
```

Check logs in stderr output or Claude Desktop logs directory.

---

## Support

For issues, questions, or feature requests:

- **GitHub Issues**: https://github.com/yourusername/tech-conf-mcp/issues
- **Documentation**: https://github.com/yourusername/tech-conf-mcp/wiki
- **Examples**: See sample queries in `/examples` directory

---

**Version**: 1.0.0  
**Last Updated**: 2025-10-02  
**License**: MIT
