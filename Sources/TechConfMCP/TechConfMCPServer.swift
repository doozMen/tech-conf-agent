import Foundation
import Logging
import MCP
import TechConfCore

actor TechConfMCPServer {
  private let server: Server
  private let logger: Logger
  private let databasePath: String?
  private var databaseManager: DatabaseManager?
  private var queries: ConferenceQueries?
  private var isInitialized = false

  init(logger: Logger, databasePath: String? = nil) throws {
    self.logger = logger
    self.databasePath = databasePath

    self.server = Server(
      name: "tech-conf-mcp",
      version: "1.0.0",
      capabilities: .init(
        prompts: nil,
        resources: nil,
        tools: .init(listChanged: false)
      )
    )
  }

  func run() async throws {
    logger.info("Starting Tech Conference MCP server...")

    // Setup handlers
    await setupHandlers()

    // Start server with stdio transport
    let transport = StdioTransport(logger: logger)
    try await server.start(transport: transport)

    logger.info("Tech Conference MCP server started successfully")
    await server.waitUntilCompleted()
  }

  // MARK: - Handler Setup

  private func setupHandlers() async {
    // List Tools Handler
    await server.withMethodHandler(ListTools.self) { [weak self] _ in
      guard let self = self else {
        throw MCPError.internalError("Server unavailable")
      }

      return await self.listTools()
    }

    // Call Tool Handler
    await server.withMethodHandler(CallTool.self) { [weak self] params in
      guard let self = self else {
        throw MCPError.internalError("Server unavailable")
      }

      return try await self.handleToolCall(
        name: params.name,
        arguments: params.arguments
      )
    }
  }

  // MARK: - Database Initialization

  private func ensureInitialized() async throws {
    guard !isInitialized else { return }

    logger.info("Initializing database...")

    // Determine database path
    let dbPath = databasePath ?? (NSHomeDirectory() + "/.tech-conf-mcp/conferences.db")
    let dbURL = URL(fileURLWithPath: dbPath)

    // Ensure directory exists
    try FileManager.default.createDirectory(
      at: dbURL.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )

    // Create database
    let database = try createConferenceDatabase(at: dbPath)
    let manager = DatabaseManager(database: database)
    self.databaseManager = manager
    self.queries = ConferenceQueries(database: manager)

    logger.info("Database initialized at: \(dbPath)")

    // Load conference data if database is empty
    let importer = DataImporter(database: manager, logger: logger)
    if try await !importer.hasData() {
      logger.info("Database is empty, loading conference data...")
      do {
        try await importer.importBundledConferenceData()
        logger.info("Conference data loaded successfully")
      } catch {
        logger.warning("Failed to load bundled conference data: \(error)")
      }
    } else {
      logger.info("Database already contains data, skipping import")
    }

    isInitialized = true
  }

  // MARK: - Tool Listing

  private func listTools() async -> ListTools.Result {
    ListTools.Result(tools: [
      Tool(
        name: "list_sessions",
        description: """
          List conference sessions with optional filtering.

          Filter sessions by various criteria including track, day, speaker, difficulty level, 
          and format. Returns detailed session information including timing, speakers, and venue.

          FILTERS:
          - track: Filter by session track (e.g., "iOS Development", "Backend")
          - day: Filter by conference day (YYYY-MM-DD format or "today")
          - speaker: Filter by speaker name (partial match)
          - difficulty: Filter by difficulty level ("beginner", "intermediate", "advanced", "all")
          - format: Filter by session format ("talk", "workshop", "panel", "keynote", "lightning")
          - isFavorited: Show only favorited sessions (true/false)
          - isUpcoming: Show only upcoming sessions (true/false)
          """,
        inputSchema: .object([
          "type": .string("object"),
          "properties": .object([
            "track": .object([
              "type": .string("string"),
              "description": .string("Filter by track name"),
              "optional": .bool(true),
            ]),
            "day": .object([
              "type": .string("string"),
              "description": .string("Filter by date (YYYY-MM-DD or 'today')"),
              "optional": .bool(true),
            ]),
            "speaker": .object([
              "type": .string("string"),
              "description": .string("Filter by speaker name (partial match)"),
              "optional": .bool(true),
            ]),
            "difficulty": .object([
              "type": .string("string"),
              "description": .string("Filter by difficulty level"),
              "enum": .array([
                .string("beginner"), .string("intermediate"), .string("advanced"), .string("all"),
              ]),
              "optional": .bool(true),
            ]),
            "format": .object([
              "type": .string("string"),
              "description": .string("Filter by session format"),
              "enum": .array([
                .string("talk"), .string("workshop"), .string("panel"), .string("keynote"),
                .string("lightning"),
              ]),
              "optional": .bool(true),
            ]),
            "isFavorited": .object([
              "type": .string("boolean"),
              "description": .string("Show only favorited sessions"),
              "optional": .bool(true),
            ]),
            "isUpcoming": .object([
              "type": .string("boolean"),
              "description": .string("Show only upcoming sessions"),
              "optional": .bool(true),
            ]),
          ]),
        ])
      ),

      Tool(
        name: "search_sessions",
        description: """
          Search sessions by title, description, or tags.

          Performs a full-text search across session titles, descriptions, abstracts, 
          and tags. Returns matching sessions with relevance scoring.
          """,
        inputSchema: .object([
          "type": .string("object"),
          "properties": .object([
            "query": .object([
              "type": .string("string"),
              "description": .string("Search query text"),
            ])
          ]),
          "required": .array([.string("query")]),
        ])
      ),

      Tool(
        name: "get_speaker",
        description: """
          Get detailed information about a specific speaker.

          Retrieve speaker details including bio, company, expertise areas, social links,
          and their scheduled sessions. Search by speaker ID or name.
          """,
        inputSchema: .object([
          "type": .string("object"),
          "properties": .object([
            "speakerId": .object([
              "type": .string("string"),
              "description": .string("Speaker UUID"),
              "optional": .bool(true),
            ]),
            "speakerName": .object([
              "type": .string("string"),
              "description": .string("Speaker name (partial match)"),
              "optional": .bool(true),
            ]),
          ]),
        ])
      ),

      Tool(
        name: "get_schedule",
        description: """
          Get the conference schedule for a specific time range.

          Returns all sessions within the specified time window, organized chronologically.
          Useful for planning your conference day or finding what's happening now.
          """,
        inputSchema: .object([
          "type": .string("object"),
          "properties": .object([
            "date": .object([
              "type": .string("string"),
              "description": .string("Date to get schedule for (YYYY-MM-DD or 'today')"),
              "optional": .bool(true),
            ]),
            "startTime": .object([
              "type": .string("string"),
              "description": .string("Start time (HH:MM format)"),
              "optional": .bool(true),
            ]),
            "endTime": .object([
              "type": .string("string"),
              "description": .string("End time (HH:MM format)"),
              "optional": .bool(true),
            ]),
          ]),
        ])
      ),

      Tool(
        name: "find_room",
        description: """
          Find room/venue information and what's happening there.

          Get details about a conference venue including capacity, floor, accessibility,
          and current/upcoming sessions in that room.
          """,
        inputSchema: .object([
          "type": .string("object"),
          "properties": .object([
            "roomName": .object([
              "type": .string("string"),
              "description": .string("Room or venue name (partial match)"),
              "optional": .bool(true),
            ]),
            "sessionId": .object([
              "type": .string("string"),
              "description": .string("Get room for a specific session UUID"),
              "optional": .bool(true),
            ]),
          ]),
        ])
      ),

      Tool(
        name: "get_session_details",
        description: """
          Get comprehensive details about a specific session.

          Returns complete session information including description, speakers, venue,
          timing, recording availability, slides, and user interactions (favorites, notes, ratings).
          """,
        inputSchema: .object([
          "type": .string("object"),
          "properties": .object([
            "sessionId": .object([
              "type": .string("string"),
              "description": .string("Session UUID"),
            ])
          ]),
          "required": .array([.string("sessionId")]),
        ])
      ),
    ])
  }

  // MARK: - Tool Call Handling

  private func handleToolCall(name: String, arguments: [String: Value]?) async throws
    -> CallTool.Result
  {
    let args = arguments ?? [:]

    do {
      let result = try await handleTool(name, arguments: args)
      return CallTool.Result(
        content: [.text(try JSONSerialization.jsonString(from: result.toJSONObject()))]
      )
    } catch {
      logger.error(
        "Tool execution failed",
        metadata: [
          "tool": .string(name),
          "error": .string(error.localizedDescription),
        ])
      throw error
    }
  }

  private func handleTool(_ toolName: String, arguments: [String: Value]) async throws -> Value {
    // Ensure database is initialized for all tools
    try await ensureInitialized()

    switch toolName {
    case "list_sessions":
      return try await handleListSessions(arguments)

    case "search_sessions":
      return try await handleSearchSessions(arguments)

    case "get_speaker":
      return try await handleGetSpeaker(arguments)

    case "get_schedule":
      return try await handleGetSchedule(arguments)

    case "find_room":
      return try await handleFindRoom(arguments)

    case "get_session_details":
      return try await handleGetSessionDetails(arguments)

    default:
      throw MCPError.methodNotFound("Unknown tool: \(toolName)")
    }
  }

  // MARK: - Tool Implementations (Placeholders)

  private func handleListSessions(_ arguments: [String: Value]) async throws -> Value {
    logger.info(
      "Handling list_sessions",
      metadata: [
        "arguments": .string(String(describing: arguments))
      ])

    guard let queries = queries else {
      throw MCPError.internalError("Database not initialized")
    }

    // Parse optional filter parameters
    let track = arguments["track"]?.stringValue
    let dayString = arguments["day"]?.stringValue
    let difficulty = arguments["difficulty"]?.stringValue
    let format = arguments["format"]?.stringValue
    let isFavorited = arguments["isFavorited"]?.boolValue
    let isUpcoming = arguments["isUpcoming"]?.boolValue

    // Parse date if provided
    var filterDate: Date?
    if let dayString = dayString {
      filterDate = DateComponents.parse(dayString)
      if filterDate == nil {
        logger.warning("Could not parse date", metadata: ["day": .string(dayString)])
        throw MCPError.invalidParams(
          "Invalid date format: \(dayString). Use YYYY-MM-DD or natural language like 'today', 'tomorrow'"
        )
      }
    }

    // Validate difficulty if provided
    let difficultyLevel: DifficultyLevel?
    if let difficulty = difficulty {
      guard let level = DifficultyLevel(rawValue: difficulty) else {
        throw MCPError.invalidParams(
          "Invalid difficulty level: \(difficulty). Must be: beginner, intermediate, advanced, or all")
      }
      difficultyLevel = level
    } else {
      difficultyLevel = nil
    }

    // Validate format if provided
    let sessionFormat: SessionFormat?
    if let format = format {
      guard let fmt = SessionFormat(rawValue: format) else {
        throw MCPError.invalidParams(
          "Invalid format: \(format). Must be: talk, workshop, panel, keynote, or lightning")
      }
      sessionFormat = fmt
    } else {
      sessionFormat = nil
    }

    // Query database
    var sessions = try await queries.listSessions(
      track: track,
      day: filterDate,
      difficultyLevel: difficultyLevel,
      format: sessionFormat
    )

    // Apply client-side filters that aren't in the database query
    if let isFavorited = isFavorited {
      sessions = sessions.filter { $0.isFavorited == isFavorited }
    }

    if let isUpcoming = isUpcoming {
      sessions = sessions.filter { $0.isUpcoming == isUpcoming }
    }

    logger.info(
      "List sessions completed",
      metadata: [
        "totalSessions": .string(String(sessions.count)),
        "filtersApplied": .string(
          String(
            describing: [
              "track": track ?? "none",
              "day": dayString ?? "none",
              "difficulty": difficulty ?? "none",
              "format": format ?? "none",
            ])),
      ])

    // Convert sessions to Value array
    return .array(sessions.map { sessionToValue($0) })
  }

  private func handleSearchSessions(_ arguments: [String: Value]) async throws -> Value {
    logger.info(
      "Handling search_sessions",
      metadata: [
        "arguments": .string(String(describing: arguments))
      ])

    guard let queries = queries else {
      throw MCPError.internalError("Database not initialized")
    }

    // Parse required query parameter
    guard let query = arguments["query"]?.stringValue else {
      throw MCPError.invalidParams("Missing required parameter: query")
    }

    if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      throw MCPError.invalidParams("Query parameter cannot be empty")
    }

    // Parse optional limit parameter
    let limit = arguments["limit"]?.intValue ?? 20
    if limit < 1 || limit > 100 {
      throw MCPError.invalidParams("Limit must be between 1 and 100")
    }

    logger.info(
      "Searching sessions",
      metadata: [
        "query": .string(query),
        "limit": .string(String(limit)),
      ])

    // Search database
    let sessions = try await queries.searchSessions(query: query, limit: limit)

    logger.info(
      "Search completed",
      metadata: [
        "matchedSessions": .string(String(sessions.count)),
      ])

    return .array(sessions.map { sessionToValue($0) })
  }

  // MARK: - Helper Functions

  /// Convert Session to MCP Value
  private func sessionToValue(_ session: Session) -> Value {
    .object([
      "id": .string(session.id.uuidString),
      "conferenceId": .string(session.conferenceId.uuidString),
      "title": .string(session.title),
      "description": .string(session.description ?? ""),
      "abstract": .string(session.abstract ?? ""),
      "startTime": .string(session.startTime.iso8601String),
      "endTime": .string(session.endTime.iso8601String),
      "track": .string(session.track ?? ""),
      "format": .string(session.format.rawValue),
      "difficultyLevel": .string(session.difficultyLevel.rawValue),
      "difficultyLabel": .string(session.difficultyLabel),
      "durationMinutes": .int(session.durationMinutes),
      "formattedDuration": .string(session.formattedDuration),
      "formattedStartTime": .string(session.formattedStartTime),
      "formattedTimeRange": .string(session.formattedTimeRange),
      "venueId": session.venueId.map { .string($0.uuidString) } ?? .null,
      "speakerIds": .string(session.speakerIds ?? "[]"),
      "tags": .array(session.tagsArray.map { .string($0) }),
      "capacity": session.capacity.map { .int($0) } ?? .null,
      "isRecorded": .bool(session.isRecorded),
      "recordingURL": session.recordingURL.map { .string($0) } ?? .null,
      "slidesURL": session.slidesURL.map { .string($0) } ?? .null,
      "isFavorited": .bool(session.isFavorited),
      "didAttend": .bool(session.didAttend),
      "notes": session.notes.map { .string($0) } ?? .null,
      "rating": session.rating.map { .int($0) } ?? .null,
      "status": .string(session.status),
      "isUpcoming": .bool(session.isUpcoming),
      "isOngoing": .bool(session.isOngoing),
      "isPast": .bool(session.isPast),
    ])
  }

  private func handleGetSpeaker(_ arguments: [String: Value]) async throws -> Value {
    guard let queries = queries else {
      throw MCPError.internalError("Database not initialized")
    }

    // Parse arguments
    let speakerId = arguments["speakerId"]?.stringValue
    let speakerName = arguments["speakerName"]?.stringValue

    // Validation: at least one parameter is required
    guard speakerId != nil || speakerName != nil else {
      throw MCPError.invalidParams("At least one of 'speakerId' or 'speakerName' is required")
    }

    logger.info(
      "Getting speaker details",
      metadata: [
        "speakerId": .string(speakerId ?? "nil"),
        "speakerName": .string(speakerName ?? "nil"),
      ])

    // Query speaker
    let speaker: Speaker?
    if let speakerIdString = speakerId, let uuid = UUID(uuidString: speakerIdString) {
      speaker = try await queries.getSpeaker(id: uuid)
    } else if let name = speakerName {
      let speakers = try await queries.findSpeakers(name: name)
      speaker = speakers.first
    } else {
      speaker = nil
    }

    guard let speaker = speaker else {
      throw MCPError.invalidParams("Speaker not found")
    }

    // Get speaker's sessions
    let sessions = try await queries.getSessionsForSpeaker(speakerId: speaker.id)

    return speakerToValue(speaker, sessions: sessions)
  }

  private func handleGetSchedule(_ arguments: [String: Value]) async throws -> Value {
    guard let queries = queries else {
      throw MCPError.internalError("Database not initialized")
    }

    // Parse arguments
    let dateString = arguments["date"]?.stringValue
    let startTimeString = arguments["startTime"]?.stringValue
    let endTimeString = arguments["endTime"]?.stringValue

    logger.info(
      "Getting schedule",
      metadata: [
        "date": .string(dateString ?? "nil"),
        "startTime": .string(startTimeString ?? "nil"),
        "endTime": .string(endTimeString ?? "nil"),
      ])

    // Parse date (default to today)
    let targetDate: Date
    if let dateString = dateString {
      targetDate = DateComponents.parse(dateString) ?? Date()
    } else {
      targetDate = Date()
    }

    // Parse time range
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    dateFormatter.timeZone = TimeZone.current

    let startTime: Date
    if let startTimeString = startTimeString,
      let parsedTime = dateFormatter.date(from: startTimeString)
    {
      let timeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)
      startTime =
        calendar.date(
          bySettingHour: timeComponents.hour ?? 0,
          minute: timeComponents.minute ?? 0,
          second: 0,
          of: targetDate) ?? targetDate.startOfDay
    } else {
      startTime = targetDate.startOfDay
    }

    let endTime: Date
    if let endTimeString = endTimeString,
      let parsedTime = dateFormatter.date(from: endTimeString)
    {
      let timeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)
      endTime =
        calendar.date(
          bySettingHour: timeComponents.hour ?? 0,
          minute: timeComponents.minute ?? 0,
          second: 59,
          of: targetDate) ?? targetDate.endOfDay
    } else {
      endTime = targetDate.endOfDay
    }

    // Query database for schedule
    let sessions = try await queries.getScheduleForTimeRange(
      start: startTime,
      end: endTime
    )

    return .object([
      "date": .string(targetDate.formattedAs("yyyy-MM-dd")),
      "dateDescription": .string(targetDate.relativeDescription),
      "startTime": .string(startTime.iso8601String),
      "endTime": .string(endTime.iso8601String),
      "totalSessions": .int(sessions.count),
      "sessions": .array(sessions.map { sessionToValue($0) }),
    ])
  }

  private func handleFindRoom(_ arguments: [String: Value]) async throws -> Value {
    guard let queries = queries else {
      throw MCPError.internalError("Database not initialized")
    }
    // Parse arguments
    let roomName = arguments["roomName"]?.stringValue
    let sessionId = arguments["sessionId"]?.stringValue

    // Validate that at least one parameter is provided
    guard roomName != nil || sessionId != nil else {
      throw MCPError.invalidParams("Either 'roomName' or 'sessionId' must be provided")
    }

    logger.info(
      "Finding room",
      metadata: [
        "roomName": .string(roomName ?? "nil"),
        "sessionId": .string(sessionId ?? "nil"),
      ])

    // Find venue
    let venue: Venue?
    if let name = roomName {
      venue = try await queries.findVenue(name: name)
    } else if let sessionIdString = sessionId, let uuid = UUID(uuidString: sessionIdString) {
      if let session = try await queries.getSession(id: uuid), let venueId = session.venueId {
        venue = try await queries.getVenue(id: venueId)
      } else {
        venue = nil
      }
    } else {
      venue = nil
    }

    guard let venue = venue else {
      throw MCPError.invalidParams("Venue not found")
    }

    // Get sessions for this venue
    let sessions = try await queries.getSessionsForVenue(venueId: venue.id)
    let now = Date()
    let currentSession = sessions.first { $0.startTime <= now && $0.endTime >= now }
    let upcomingSessions = sessions.filter { $0.isUpcoming }.prefix(3)

    var result = venueToValue(venue)

    // Add current and upcoming sessions
    if let current = currentSession {
      result = result.with(key: "currentSession", value: sessionToValue(current))
    }

    result = result.with(key: "upcomingSessions", value: .array(upcomingSessions.map { sessionToValue($0) }))

    return result
  }

  private func handleGetSessionDetails(_ arguments: [String: Value]) async throws -> Value {
    guard let queries = queries else {
      throw MCPError.internalError("Database not initialized")
    }

    // Parse required sessionId parameter
    guard let sessionIdString = arguments["sessionId"]?.stringValue,
          let sessionId = UUID(uuidString: sessionIdString) else {
      throw MCPError.invalidParams("'sessionId' parameter is required and must be a valid UUID")
    }

    logger.info(
      "Getting session details",
      metadata: [
        "sessionId": .string(sessionIdString)
      ])

    // Get session from database
    guard let session = try await queries.getSession(id: sessionId) else {
      throw MCPError.invalidParams("Session not found")
    }

    return sessionToValue(session)
  }

  // MARK: - Helper Functions for Value Conversion

  /// Convert Speaker to MCP Value with sessions
  private func speakerToValue(_ speaker: Speaker, sessions: [Session]) -> Value {
    // Parse social links JSON
    var socialLinksDict: [String: Value] = [:]
    if let socialLinksStr = speaker.socialLinks,
       let data = socialLinksStr.data(using: .utf8),
       let dict = try? JSONDecoder().decode([String: String].self, from: data) {
      socialLinksDict = dict.mapValues { .string($0) }
    }

    // Parse expertise JSON
    var expertiseArray: [Value] = []
    if let expertiseStr = speaker.expertise,
       let data = expertiseStr.data(using: .utf8),
       let array = try? JSONDecoder().decode([String].self, from: data) {
      expertiseArray = array.map { .string($0) }
    }

    return .object([
      "id": .string(speaker.id.uuidString),
      "name": .string(speaker.name),
      "title": speaker.title.map { .string($0) } ?? .null,
      "company": speaker.company.map { .string($0) } ?? .null,
      "bio": speaker.bio.map { .string($0) } ?? .null,
      "shortBio": speaker.shortBio.map { .string($0) } ?? .null,
      "email": speaker.email.map { .string($0) } ?? .null,
      "socialLinks": .object(socialLinksDict),
      "websiteURL": speaker.websiteURL.map { .string($0) } ?? .null,
      "photoURL": speaker.photoURL.map { .string($0) } ?? .null,
      "expertise": .array(expertiseArray),
      "yearsExperience": speaker.yearsExperience.map { .int($0) } ?? .null,
      "isKeynoteSpeaker": .bool(speaker.isKeynoteSpeaker),
      "location": speaker.location.map { .string($0) } ?? .null,
      "sessions": .array(sessions.map { sessionToValue($0) }),
      "stats": .object([
        "totalSessions": .int(sessions.count),
        "yearsExperience": speaker.yearsExperience.map { .int($0) } ?? .int(0),
      ]),
    ])
  }

  /// Convert Venue to MCP Value
  private func venueToValue(_ venue: Venue) -> Value {
    // Parse accessibility JSON
    var accessibilityDict: [String: Value] = [:]
    if let accessibilityStr = venue.accessibility,
       let data = accessibilityStr.data(using: .utf8),
       let dict = try? JSONDecoder().decode([String: Bool].self, from: data) {
      accessibilityDict = dict.mapValues { .bool($0) }
    }

    // Parse equipment JSON
    var equipmentArray: [Value] = []
    if let equipmentStr = venue.equipment,
       let data = equipmentStr.data(using: .utf8),
       let array = try? JSONDecoder().decode([String].self, from: data) {
      equipmentArray = array.map { .string($0) }
    }

    // Parse coordinates JSON
    var coordinatesDict: [String: Value] = [:]
    if let coordinatesStr = venue.coordinates,
       let data = coordinatesStr.data(using: .utf8),
       let dict = try? JSONDecoder().decode([String: Double].self, from: data) {
      coordinatesDict = dict.mapValues { .double($0) }
    }

    // Build basic information
    var dict: [String: Value] = [
      "id": .string(venue.id.uuidString),
      "conferenceId": .string(venue.conferenceId.uuidString),
      "name": .string(venue.name),
    ]

    // Add optional basic fields
    if let description = venue.description { dict["description"] = .string(description) }
    if let building = venue.building { dict["building"] = .string(building) }
    if let floor = venue.floor { dict["floor"] = .string(floor) }
    if let roomNumber = venue.roomNumber { dict["roomNumber"] = .string(roomNumber) }
    dict["capacity"] = .int(venue.capacity)
    if let seatingArrangement = venue.seatingArrangement { dict["seatingArrangement"] = .string(seatingArrangement) }

    // Add boolean flags
    dict["hasStandingRoom"] = .bool(venue.hasStandingRoom)
    dict["isWheelchairAccessible"] = .bool(venue.isWheelchairAccessible)
    dict["hasLiveStream"] = .bool(venue.hasLiveStream)
    dict["isVirtual"] = .bool(venue.isVirtual)
    dict["isFavorited"] = .bool(venue.isFavorited)

    // Add parsed JSON fields
    dict["accessibility"] = .object(accessibilityDict)
    dict["equipment"] = .array(equipmentArray)
    dict["coordinates"] = .object(coordinatesDict)

    // Add more optional fields
    if let accessibilityNotes = venue.accessibilityNotes { dict["accessibilityNotes"] = .string(accessibilityNotes) }
    if let wifiNetwork = venue.wifiNetwork { dict["wifiNetwork"] = .string(wifiNetwork) }
    if let liveStreamURL = venue.liveStreamURL { dict["liveStreamURL"] = .string(liveStreamURL) }
    if let address = venue.address { dict["address"] = .string(address) }
    if let directions = venue.directions { dict["directions"] = .string(directions) }
    if let virtualPlatform = venue.virtualPlatform { dict["virtualPlatform"] = .string(virtualPlatform) }
    if let virtualMeetingURL = venue.virtualMeetingURL { dict["virtualMeetingURL"] = .string(virtualMeetingURL) }
    if let notes = venue.notes { dict["notes"] = .string(notes) }

    return .object(dict)
  }
}

// MARK: - Value Extensions

extension Value {
  /// Create a new Value with an additional key-value pair (for .object only)
  func with(key: String, value: Value) -> Value {
    guard case .object(var dict) = self else {
      return self
    }
    dict[key] = value
    return .object(dict)
  }
}

// MARK: - JSON Serialization Helper

extension JSONSerialization {
  fileprivate static func jsonString(from object: Any) throws -> String {
    let data = try JSONSerialization.data(
      withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
    guard let string = String(data: data, encoding: .utf8) else {
      throw NSError(
        domain: "JSONSerializationError", code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Could not convert JSON data to string"])
    }
    return string
  }
}
