# Tech Conference MCP Server - Development Guidelines

**Project**: tech-conf-mcp  
**Language**: Swift 6.2  
**Platform**: macOS 15.0+  
**Architecture**: Actor-based MCP server with SQLite backend

---

## Project Overview

Tech Conference MCP Server is a Model Context Protocol (MCP) server that provides structured access to conference data through natural language queries. It enables AI assistants like Claude to help users navigate technical conferences by querying sessions, speakers, schedules, and venues.

### Core Capabilities

- **6 MCP Tools**: `list_sessions`, `search_sessions`, `get_speaker`, `get_schedule`, `find_room`, `get_session_details`
- **Natural Language Processing**: Supports date parsing ("today", "tomorrow", "next monday") and fuzzy search
- **SQLite Backend**: GRDB.swift for type-safe database access with migrations
- **Stdio Transport**: JSON-RPC protocol over stdin/stdout for MCP communication

---

## Architecture

### 3-Module Structure

```
tech-conf-mcp/
├── Sources/
│   ├── TechConfCore/         # Domain models & database layer
│   │   ├── Models/            # Session, Speaker, Venue, Conference
│   │   ├── Database/          # DatabaseManager, migrations
│   │   └── Queries/           # ConferenceQueries (repository pattern)
│   │
│   ├── TechConfMCP/          # MCP server implementation
│   │   ├── TechConfMCP.swift         # CLI entry point (@main)
│   │   ├── TechConfMCPServer.swift   # Actor-based MCP server
│   │   ├── ValueExtensions.swift     # MCP Value conversions
│   │   └── DateParsingExtensions.swift  # Natural language date parsing
│   │
│   └── TechConfSync/         # Future: External data sync (placeholder)
```

### Key Components

1. **TechConfCore** (Domain Layer)
   - GRDB models: `Session`, `Speaker`, `Venue`, `Conference`
   - Database migrations with foreign key constraints
   - Type-safe query methods via `ConferenceQueries`
   - Actor-isolated `DatabaseManager` for concurrency safety

2. **TechConfMCP** (MCP Protocol Layer)
   - `TechConfMCPServer`: Actor-isolated server handling tool calls
   - Stdio transport for JSON-RPC communication
   - Value conversion utilities for Swift ↔ MCP protocol
   - Date parsing extensions for natural language support

3. **TechConfSync** (Future)
   - Placeholder for external data sync (conference APIs, web scraping)
   - Currently disabled pending TechConfCore completion

---

## Development Guidelines

### Swift 6.2 Patterns

**Strict Concurrency Enforcement**:
```swift
// ✅ Use actor isolation for shared state
actor TechConfMCPServer {
    private let server: Server
    private let logger: Logger
    // All methods automatically isolated to actor's serial executor
}

// ✅ Mark sendable types properly
public struct Session: Sendable, Codable, FetchableRecord {
    // All properties must be Sendable
}

// ✅ Use @Sendable closures for database operations
public func read<T: Sendable>(_ block: @Sendable @escaping (Database) throws -> T) async throws -> T {
    try await database.read { db in
        try block(db)
    }
}
```

**Avoid Common Pitfalls**:
```swift
// ❌ Don't capture non-Sendable types in async contexts
var localCache: [String: Session] = [:]  // Non-Sendable!
Task {
    localCache["key"] = session  // Compiler error with strict concurrency
}

// ✅ Use actor-isolated properties or Sendable containers
actor Cache {
    private var sessions: [String: Session] = [:]
    func store(_ session: Session, for key: String) { ... }
}
```

### Actor-Based Concurrency Requirements

**All MCP Tool Handlers Must Be Actor-Isolated**:
```swift
actor TechConfMCPServer {
    // ✅ Tool handlers automatically actor-isolated
    private func handleListSessions(_ arguments: [String: Value]) async throws -> Value {
        // Safe to access actor properties
        try await ensureInitialized()
        // Perform queries
    }
    
    // ✅ Database access is async and Sendable-safe
    private func ensureInitialized() async throws {
        guard !isInitialized else { return }
        // Initialize database
        isInitialized = true
    }
}
```

**Database Actor Pattern**:
```swift
public actor DatabaseManager {
    private let database: DatabasePool
    
    // ✅ All database operations are async and actor-isolated
    public func read<T: Sendable>(_ block: @Sendable @escaping (Database) throws -> T) async throws -> T {
        try await database.read { db in
            try block(db)
        }
    }
}
```

### Testing Requirements (Swift Testing)

**Use Swift Testing Framework** (NOT XCTest):
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
    
    @Test("Search sessions returns relevant results")
    func searchSessions() async throws {
        let db = try createTestDatabase()
        let queries = ConferenceQueries(database: db)
        
        let results = try await queries.searchSessions(query: "Swift")
        #expect(!results.isEmpty)
        #expect(results.first?.title.contains("Swift") == true)
    }
}
```

**Testing Patterns**:
- Use `@Suite` for test organization
- Use `@Test` for individual test cases
- Use `#expect()` for assertions (not `XCTAssert`)
- Create isolated test databases for each test
- Test async code with `async throws` test methods

### Code Style (swift-format)

**Formatting Commands**:
```bash
# Lint the project
swift format lint -s -p -r Sources Tests Package.swift

# Auto-format files
swift format format -p -r -i Sources Tests Package.swift
```

**Style Conventions**:
- 2-space indentation (not tabs)
- Max line length: 100 characters
- Use trailing commas in multi-line arrays/dictionaries
- Sort imports alphabetically
- Use explicit `self.` only when required for disambiguation

**Example**:
```swift
// ✅ Good formatting
public struct Session: Sendable, Codable {
  public let id: UUID
  public var title: String
  public var startTime: Date
  
  public init(
    id: UUID = UUID(),
    title: String,
    startTime: Date
  ) {
    self.id = id
    self.title = title
    self.startTime = startTime
  }
}

// ❌ Bad formatting (tabs, inconsistent spacing)
public struct Session:Sendable,Codable{
    public let id:UUID
    public var title:String
}
```

---

## Database Schema & Migrations

### Schema Overview

**Core Tables**:
```sql
-- conference: Top-level conference data
CREATE TABLE conference (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    startDate TEXT NOT NULL,  -- ISO8601
    endDate TEXT NOT NULL,    -- ISO8601
    location TEXT,
    timezone TEXT DEFAULT 'UTC',
    website TEXT,
    createdAt TEXT DEFAULT CURRENT_TIMESTAMP
);

-- speaker: Speaker profiles
CREATE TABLE speaker (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    bio TEXT,                -- Full professional biography
    title TEXT,              -- Professional title (e.g., "Senior Software Engineer")
    company TEXT,            -- Company/organization affiliation
    email TEXT,              -- Contact email
    twitter TEXT,            -- Twitter/X handle
    github TEXT,             -- GitHub profile URL
    linkedin TEXT,           -- LinkedIn profile URL
    website TEXT,            -- Personal website
    expertise TEXT,          -- JSON array of expertise areas
    photoURL TEXT,           -- Profile photo URL
    createdAt TEXT DEFAULT CURRENT_TIMESTAMP
);

-- venue: Conference venues/rooms
CREATE TABLE venue (
    id TEXT PRIMARY KEY,
    conferenceId TEXT NOT NULL REFERENCES conference(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    capacity INTEGER,
    floor TEXT,
    accessibility TEXT,  -- JSON
    createdAt TEXT DEFAULT CURRENT_TIMESTAMP
);

-- session: Conference sessions
CREATE TABLE session (
    id TEXT PRIMARY KEY,
    conferenceId TEXT NOT NULL REFERENCES conference(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    speakerId TEXT REFERENCES speaker(id) ON DELETE SET NULL,
    startTime TEXT NOT NULL,  -- ISO8601
    endTime TEXT NOT NULL,    -- ISO8601
    venueId TEXT REFERENCES venue(id) ON DELETE SET NULL,
    track TEXT,
    format TEXT,  -- talk, workshop, panel, keynote, lightning
    difficultyLevel TEXT,  -- beginner, intermediate, advanced, all
    tags TEXT,  -- JSON array
    createdAt TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### Speaker Model Structure

The database includes comprehensive speaker data from **ServerSide.swift 2025 London**:

**Speaker Model Example** (Adam Fowler):
```swift
public struct Speaker: Sendable, Codable {
    public let id: UUID
    public var name: String                    // "Adam Fowler"
    public var bio: String?                    // Full professional biography
    public var title: String?                  // "Senior Software Engineer"
    public var company: String?                // "Apple"
    public var email: String?                  // Contact email
    public var twitter: String?                // "@adamfowler"
    public var github: String?                 // "https://github.com/adam-fowler"
    public var linkedin: String?               // LinkedIn profile
    public var website: String?                // Personal website
    public var expertise: [String]?            // ["Hummingbird", "AWS", "Cloud Infrastructure"]
    public var photoURL: String?               // Profile photo
}
```

**Real Speaker Data** (from ServerSide.swift 2025):
```sql
INSERT INTO speaker VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    'Adam Fowler',
    'Maintainer of Hummingbird framework and Soto AWS SDK. Expert in cloud infrastructure, serverless Swift applications, and building production-ready server-side Swift libraries.',
    'Senior Software Engineer',
    'Apple',
    null,
    '@adamfowler',
    'https://github.com/adam-fowler',
    null,
    null,
    '["Hummingbird", "AWS", "Cloud Infrastructure", "Serverless", "Redis/Valkey"]',
    '/App/Images/speakers/adam-fowler.jpg'
);
```

**Speaker Categories**:
- **27+ total speakers** including Apple engineers, framework creators, production experts
- **Apple Swift Server team**: Franz Busch, George Barnett, Honza Dvorsky, Ben Cohen, Si Beaumont, Eric Ernst, Agam Dua
- **Framework maintainers**: Adam Fowler (Hummingbird), Joannis Orlandos (MongoKitten)
- **Production speakers**: Ben Rosen (SongShift), Mikaela Caron (Vapor), Daniel Jilg (TelemetryDeck)

### Migration Pattern

**Adding New Migrations**:
```swift
// In DatabaseManager.swift
var migrator = DatabaseMigrator()

migrator.registerMigration("v1_initial_schema") { db in
    // Initial schema creation
}

migrator.registerMigration("v2_add_session_metadata") { db in
    try db.alter(table: "session") { t in
        t.add(column: "isRecorded", .boolean).defaults(to: false)
        t.add(column: "recordingURL", .text)
    }
}

// Run migrations
try migrator.migrate(database)
```

**Migration Best Practices**:
- Never modify existing migrations
- Always create new migrations for schema changes
- Test migrations with production-like data
- Include rollback instructions in migration comments
- Use foreign keys for referential integrity

---

## Tool Development

### Adding New MCP Tools

**Step 1: Register Tool in `listTools()`**:
```swift
private func listTools() async -> ListTools.Result {
    ListTools.Result(tools: [
        // Existing tools...
        
        Tool(
            name: "get_favorites",
            description: """
            Get user's favorited sessions across all conferences.
            
            Returns sessions marked as favorites, ordered by start time.
            Useful for building a personalized conference schedule.
            """,
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "conferenceId": .object([
                        "type": .string("string"),
                        "description": .string("Filter by conference UUID"),
                        "optional": .bool(true),
                    ])
                ]),
            ])
        ),
    ])
}
```

**Step 2: Add Tool Handler**:
```swift
private func handleTool(_ toolName: String, arguments: [String: Value]) async throws -> Value {
    try await ensureInitialized()
    
    switch toolName {
    case "get_favorites":
        return try await handleGetFavorites(arguments)
    // ... other cases
    default:
        throw MCPError.methodNotFound("Unknown tool: \(toolName)")
    }
}

private func handleGetFavorites(_ arguments: [String: Value]) async throws -> Value {
    logger.info("Handling get_favorites")
    
    let conferenceId = arguments["conferenceId"]?.stringValue
        .flatMap { UUID(uuidString: $0) }
    
    // Query database
    let sessions = try await queries.getFavoritedSessions(conferenceId: conferenceId)
    
    // Convert to MCP Value
    return .array(sessions.map { Value.from($0) })
}
```

**Step 3: Add Database Query Method** (if needed):
```swift
// In ConferenceQueries.swift
public func getFavoritedSessions(conferenceId: UUID? = nil) async throws -> [Session] {
    try await database.read { db in
        var sql = "SELECT * FROM session WHERE isFavorited = 1"
        var arguments: [DatabaseValueConvertible] = []
        
        if let conferenceId = conferenceId {
            sql += " AND conferenceId = ?"
            arguments.append(conferenceId.uuidString)
        }
        
        sql += " ORDER BY startTime ASC"
        
        let rows = try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
        return rows.compactMap { try? Session(row: $0) }
    }
}
```

### Value Conversion Patterns

**Swift → MCP Value**:
```swift
extension Value {
    static func from(_ session: Session) -> Value {
        var dict: [String: Value] = [
            "id": .string(session.id.uuidString),
            "title": .string(session.title),
            "startTime": .string(ISO8601DateFormatter().string(from: session.startTime)),
            // Required fields...
        ]
        
        // Optional fields (use conditional unwrapping)
        if let description = session.description {
            dict["description"] = .string(description)
        }
        
        // Computed properties
        dict["isUpcoming"] = .bool(session.isUpcoming)
        dict["formattedDuration"] = .string(session.formattedDuration)
        
        return .object(dict)
    }
}
```

**MCP Value → Swift**:
```swift
// Parsing tool arguments
let sessionId = arguments["sessionId"]?.stringValue
    .flatMap { UUID(uuidString: $0) }

let difficulty = arguments["difficulty"]?.stringValue
    .flatMap { DifficultyLevel(rawValue: $0) }

let startTime = arguments["startTime"]?.stringValue
    .flatMap { DateComponents.parse($0) }
```

### Error Handling Conventions

**Use Typed Errors**:
```swift
public enum QueryError: LocalizedError {
    case invalidDateRange
    case notFound(String)
    case invalidQuery(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidDateRange:
            return "Invalid date range specified"
        case .notFound(let item):
            return "\(item) not found"
        case .invalidQuery(let reason):
            return "Invalid query: \(reason)"
        }
    }
}
```

**Throw MCP Errors for Protocol Issues**:
```swift
// Invalid parameters
guard let query = arguments["query"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: query")
}

// Unknown tool
throw MCPError.methodNotFound("Unknown tool: \(toolName)")

// Internal errors
throw MCPError.internalError("Database initialization failed")
```

---

## Testing Strategy

### Unit Tests

**Test Database Queries**:
```swift
@Suite("Session Query Tests")
struct SessionQueryTests {
    
    @Test("Filter sessions by difficulty level")
    func filterByDifficulty() async throws {
        let db = try createTestDatabase()
        await seedTestData(db)
        
        let queries = ConferenceQueries(database: db)
        let beginnerSessions = try await queries.listSessions(
            difficultyLevel: .beginner
        )
        
        #expect(beginnerSessions.allSatisfy { $0.difficultyLevel == .beginner })
    }
}
```

**Test Date Parsing**:
```swift
@Suite("Date Parsing Tests")
struct DateParsingTests {
    
    @Test("Parse natural language dates")
    func parseNaturalLanguage() {
        let today = DateComponents.parse("today")
        #expect(today != nil)
        #expect(Calendar.current.isDateInToday(today!))
        
        let tomorrow = DateComponents.parse("tomorrow")
        #expect(tomorrow != nil)
        #expect(Calendar.current.isDateInTomorrow(tomorrow!))
    }
    
    @Test("Parse ISO 8601 dates")
    func parseISO8601() {
        let date = DateComponents.parse("2025-10-15")
        #expect(date != nil)
        
        let dateTime = DateComponents.parse("2025-10-15T14:30:00Z")
        #expect(dateTime != nil)
    }
}
```

### Integration Tests

**Test MCP Protocol**:
```swift
@Suite("MCP Server Integration Tests")
struct MCPServerTests {
    
    @Test("List tools returns all expected tools")
    func listTools() async throws {
        let server = try TechConfMCPServer(logger: testLogger)
        let result = await server.listTools()
        
        let toolNames = result.tools.map(\.name)
        #expect(toolNames.contains("list_sessions"))
        #expect(toolNames.contains("search_sessions"))
        #expect(toolNames.contains("get_speaker"))
    }
}
```

### Test Helpers

**Create Test Database**:
```swift
func createTestDatabase() throws -> DatabasePool {
    let db = try DatabasePool()  // In-memory
    var migrator = DatabaseMigrator()
    // Add migrations...
    try migrator.migrate(db)
    return db
}

func seedTestData(_ db: DatabasePool) async throws {
    try await db.write { db in
        let conference = Conference(
            id: UUID(),
            name: "Test Conference 2025",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 3)
        )
        try conference.insert(db)
        
        // Add sessions, speakers, venues...
    }
}
```

---

## Common Tasks

### Adding New Conference Data

**Manual SQL Insertion**:
```bash
sqlite3 ~/.tech-conf-mcp/conferences.db

INSERT INTO conference (id, name, startDate, endDate, location, timezone)
VALUES (
    lower(hex(randomblob(16))),
    'ServerSide.swift 2025',
    '2025-10-15T00:00:00Z',
    '2025-10-17T23:59:59Z',
    'San Francisco, CA',
    'America/Los_Angeles'
);

INSERT INTO session (id, conferenceId, title, startTime, endTime, track, format)
VALUES (
    lower(hex(randomblob(16))),
    (SELECT id FROM conference WHERE name = 'ServerSide.swift 2025'),
    'Swift Concurrency Deep Dive',
    '2025-10-15T14:00:00Z',
    '2025-10-15T15:30:00Z',
    'Server-Side Swift',
    'talk'
);
```

**Programmatic Data Seeding** (future TechConfSync):
```swift
// In TechConfSync module
public actor ConferenceSync {
    public func importConference(from url: URL) async throws {
        let data = try Data(contentsOf: url)
        let conference = try JSONDecoder().decode(Conference.self, from: data)
        
        try await database.write { db in
            try conference.insert(db)
            for session in conference.sessions {
                try session.insert(db)
            }
        }
    }
}
```

### Updating Models

**Adding Optional Field**:
```swift
// 1. Update model
public struct Session: Sendable, Codable {
    // Existing fields...
    public var recordingURL: String?  // New field
}

// 2. Create migration
migrator.registerMigration("v2_add_recording_url") { db in
    try db.alter(table: "session") { t in
        t.add(column: "recordingURL", .text)
    }
}

// 3. Update Row decoder
extension Session {
    init(row: Row) throws {
        self.init(
            // Existing fields...
            recordingURL: row["recordingURL"]
        )
    }
}

// 4. Update Value conversion
extension Value {
    static func from(_ session: Session) -> Value {
        var dict: [String: Value] = [ /* ... */ ]
        if let recordingURL = session.recordingURL {
            dict["recordingURL"] = .string(recordingURL)
        }
        return .object(dict)
    }
}
```

**Adding Computed Property**:
```swift
extension Session {
    /// Whether recording is available
    public var hasRecording: Bool {
        recordingURL != nil && isPast
    }
    
    /// Recording status message
    public var recordingStatus: String {
        if isPast && hasRecording {
            return "Recording available"
        } else if isPast && !hasRecording {
            return "No recording"
        } else {
            return "Session not yet recorded"
        }
    }
}
```

### Adding New Query Methods

**Pattern for Complex Queries**:
```swift
// In ConferenceQueries.swift
public func getPopularSessions(
    conferenceId: UUID,
    minAttendees: Int = 100
) async throws -> [Session] {
    try await database.read { db in
        let sql = """
            SELECT s.*
            FROM session s
            INNER JOIN venue v ON s.venueId = v.id
            WHERE s.conferenceId = ?
              AND v.capacity >= ?
            ORDER BY v.capacity DESC, s.startTime ASC
            """
        
        let rows = try Row.fetchAll(
            db,
            sql: sql,
            arguments: [conferenceId.uuidString, minAttendees]
        )
        
        return rows.compactMap { try? Session(row: $0) }
    }
}
```

---

## MCP Protocol Notes

### Stdio Transport Details

**Communication Flow**:
```
1. Claude Desktop launches: tech-conf-mcp --log-level info
2. Server initializes stdio transport (stdin/stdout)
3. Claude sends JSON-RPC messages over stdin
4. Server responds via stdout
5. Logs written to stderr
```

**Message Format**:
```json
// Request (from Claude)
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "list_sessions",
    "arguments": {
      "track": "iOS Development",
      "day": "tomorrow"
    }
  }
}

// Response (from server)
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "[{\"id\":\"...\",\"title\":\"...\"}]"
      }
    ]
  }
}
```

### Tool Registration Pattern

**Tool Definition Structure**:
```swift
Tool(
    name: "tool_name",           // Snake_case identifier
    description: """              // Detailed description for Claude
        What the tool does.
        
        Include parameter explanations and examples.
        """,
    inputSchema: .object([       // JSON Schema definition
        "type": .string("object"),
        "properties": .object([
            "param1": .object([
                "type": .string("string"),
                "description": .string("What param1 does"),
                "optional": .bool(true),
            ]),
        ]),
        "required": .array([.string("param1")]),  // Required params
    ])
)
```

**Best Practices**:
- Use descriptive tool names (verb + noun: `list_sessions`, `get_speaker`)
- Provide detailed descriptions with examples
- Mark optional parameters explicitly
- Include parameter validation in handler
- Return structured JSON responses

---

## Build & Deployment

### Build Commands

```bash
# Debug build
swift build

# Release build (optimized)
swift build -c release

# Skip plugin validation (if macro issues)
swift build -c release \
  -Xswiftc -skipPackagePluginValidation \
  -Xswiftc -skipMacroValidation

# Clean build artifacts
swift package clean
```

### Installation

```bash
# Remove existing installation
rm -f ~/.swiftpm/bin/tech-conf-mcp

# Install from source
swift package experimental-install

# Verify installation
~/.swiftpm/bin/tech-conf-mcp --version
```

### Running Tests

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter ConferenceQueriesTests

# Run with verbose output
swift test --verbose
```

---

## Troubleshooting Development Issues

### GRDB Concurrency Warnings

**Issue**: "Actor-isolated property accessed from non-isolated context"

**Solution**: Ensure all database access is through actor-isolated methods
```swift
// ❌ Bad: Direct database access
let sessions = try database.read { db in ... }

// ✅ Good: Actor-isolated wrapper
actor DatabaseManager {
    func read<T: Sendable>(_ block: @Sendable (Database) throws -> T) async throws -> T {
        try await database.read(block)
    }
}
```

### MCP Protocol Errors

**Issue**: "Method not found" errors

**Solution**: Verify tool registration and handler routing
```swift
// Check tool is registered in listTools()
// Check handler exists in handleTool() switch statement
// Check tool name matches exactly (case-sensitive)
```

### Date Parsing Failures

**Issue**: Natural language dates not parsing

**Solution**: Check DateComponents.parse() implementation
```swift
// Debug parsing
let date = DateComponents.parse("tomorrow")
logger.debug("Parsed date: \(date?.iso8601String ?? "nil")")

// Supported formats documented in DateParsingExtensions.swift
```

---

## Git Workflow

### Commit Messages

Follow conventional commit format:
```
feat: Add get_favorites tool for personalized schedules
fix: Correct date parsing for "next week" queries
docs: Update USAGE.md with new tool examples
refactor: Extract date parsing to separate module
test: Add unit tests for ConferenceQueries
```

### Branch Strategy

- `main`: Stable releases
- `develop`: Integration branch
- `feature/*`: New features
- `fix/*`: Bug fixes
- `docs/*`: Documentation updates

### Pre-commit Checks

```bash
# Format code
swift format format -p -r -i Sources Tests Package.swift

# Run tests
swift test

# Lint
swift format lint -s -p -r Sources Tests Package.swift
```

---

## Important Reminders

1. **Never build custom formatters** - Swift 6 has built-in swift-format
2. **Use Swift Testing** - NOT XCTest (removed from dependencies)
3. **Actor isolation is mandatory** - All shared state must be actor-protected
4. **Database paths are configurable** - Use --db-path for custom locations
5. **PATH must include ~/.swiftpm/bin** - Required for Claude Desktop integration
6. **Logs go to stderr** - stdout is reserved for MCP protocol JSON-RPC
7. **Value conversions are critical** - All Swift types must convert to MCP Value format
8. **Migrations are immutable** - Never modify existing migrations, always add new ones

---

**Last Updated**: 2025-10-02  
**Swift Version**: 6.2  
**MCP SDK**: swift-sdk (main branch)
