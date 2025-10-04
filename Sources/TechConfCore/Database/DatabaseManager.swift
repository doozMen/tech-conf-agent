import Foundation
import GRDB
import Logging

/// Creates and configures the TechConf database with migration-based schema
public func createConferenceDatabase(at path: String? = nil) throws -> any DatabaseWriter {
  var configuration = Configuration()
  configuration.foreignKeysEnabled = true

  let database: any DatabaseWriter
  if let path = path {
    // File-based database
    let databaseURL = URL(fileURLWithPath: path)

    // Create directory if needed
    try FileManager.default.createDirectory(
      at: databaseURL.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )

    database = try DatabasePool(path: databaseURL.path, configuration: configuration)
  } else {
    // In-memory database for testing - use DatabaseQueue since WAL mode doesn't work in-memory
    database = try DatabaseQueue(configuration: configuration)
  }

  var migrator = DatabaseMigrator()

  // MARK: - v1_initial_schema Migration

  migrator.registerMigration("v1_initial_schema") { db in
    // Conference table
    try db.create(table: "conference", options: [.strict]) { t in
      t.column("id", .text).primaryKey().notNull()
      t.column("name", .text).notNull()
      t.column("startDate", .text).notNull()  // ISO8601 format
      t.column("endDate", .text).notNull()  // ISO8601 format
      t.column("location", .text)
      t.column("timezone", .text).notNull().defaults(sql: "'UTC'")
      t.column("website", .text)
      t.column("createdAt", .text).notNull().defaults(sql: "CURRENT_TIMESTAMP")
      t.column("updatedAt", .text).notNull().defaults(sql: "CURRENT_TIMESTAMP")
    }

    // Index for date-based queries
    try db.create(
      index: "idx_conference_dates", on: "conference", columns: ["startDate", "endDate"])

    // Speaker table
    try db.create(table: "speaker", options: [.strict]) { t in
      t.column("id", .text).primaryKey().notNull()
      t.column("name", .text).notNull()
      t.column("bio", .text)
      t.column("company", .text)
      t.column("twitter", .text)
      t.column("website", .text)
      t.column("createdAt", .text).notNull().defaults(sql: "CURRENT_TIMESTAMP")
      t.column("updatedAt", .text).notNull().defaults(sql: "CURRENT_TIMESTAMP")
    }

    // Index for name searches
    try db.create(index: "idx_speaker_name", on: "speaker", columns: ["name"])

    // Venue table
    try db.create(table: "venue", options: [.strict]) { t in
      t.column("id", .text).primaryKey().notNull()
      t.column("conferenceId", .text).notNull()
        .references("conference", column: "id", onDelete: .cascade, onUpdate: .cascade)
      t.column("name", .text).notNull()
      t.column("capacity", .integer)
      t.column("floor", .text)
      t.column("accessibility", .text)
      t.column("createdAt", .text).notNull().defaults(sql: "CURRENT_TIMESTAMP")
      t.column("updatedAt", .text).notNull().defaults(sql: "CURRENT_TIMESTAMP")
    }

    // Index for conference-based queries
    try db.create(index: "idx_venue_conference", on: "venue", columns: ["conferenceId"])

    // Session table
    try db.create(table: "session", options: [.strict]) { t in
      t.column("id", .text).primaryKey().notNull()
      t.column("conferenceId", .text).notNull()
        .references("conference", column: "id", onDelete: .cascade, onUpdate: .cascade)
      t.column("title", .text).notNull()
      t.column("description", .text)
      t.column("speakerId", .text)
        .references("speaker", column: "id", onDelete: .setNull, onUpdate: .cascade)
      t.column("startTime", .text).notNull()  // ISO8601 format
      t.column("endTime", .text).notNull()  // ISO8601 format
      t.column("venueId", .text)
        .references("venue", column: "id", onDelete: .setNull, onUpdate: .cascade)
      t.column("track", .text)
      t.column("format", .text)  // e.g., "talk", "workshop", "panel", "keynote"
      t.column("difficultyLevel", .text)  // e.g., "beginner", "intermediate", "advanced"
      t.column("tags", .text)  // JSON array of tags
      t.column("createdAt", .text).notNull().defaults(sql: "CURRENT_TIMESTAMP")
      t.column("updatedAt", .text).notNull().defaults(sql: "CURRENT_TIMESTAMP")
    }

    // Indices for performance
    try db.create(index: "idx_session_conference", on: "session", columns: ["conferenceId"])
    try db.create(index: "idx_session_time", on: "session", columns: ["startTime", "endTime"])
    try db.create(index: "idx_session_speaker", on: "session", columns: ["speakerId"])
    try db.create(index: "idx_session_venue", on: "session", columns: ["venueId"])
    try db.create(index: "idx_session_track", on: "session", columns: ["track"])
  }

  // MARK: - v2_extend_session_schema Migration

  migrator.registerMigration("v2_extend_session_schema") { db in
    // Add comprehensive session fields
    try db.alter(table: "session") { t in
      t.add(column: "abstract", .text)
      t.add(column: "durationMinutes", .integer)
      t.add(column: "capacity", .integer)
      t.add(column: "isRecorded", .integer).notNull().defaults(to: 0)
      t.add(column: "recordingURL", .text)
      t.add(column: "slidesURL", .text)
      t.add(column: "isFavorited", .integer).notNull().defaults(to: 0)
      t.add(column: "didAttend", .integer).notNull().defaults(to: 0)
      t.add(column: "notes", .text)
      t.add(column: "rating", .integer)
      t.add(column: "speakerIds", .text)  // JSON array for multi-speaker support
    }
  }

  // MARK: - v3_extend_speaker_schema Migration

  migrator.registerMigration("v3_extend_speaker_schema") { db in
    // Add comprehensive speaker fields
    try db.alter(table: "speaker") { t in
      t.add(column: "title", .text)
      t.add(column: "shortBio", .text)
      t.add(column: "email", .text)
      t.add(column: "socialLinks", .text)  // JSON object {"twitter": "@handle", ...}
      t.add(column: "websiteURL", .text)
      t.add(column: "photoURL", .text)
      t.add(column: "expertise", .text)  // JSON array ["iOS", "Swift", ...]
      t.add(column: "previousConferences", .text)  // JSON array
      t.add(column: "yearsExperience", .integer)
      t.add(column: "isKeynoteSpeaker", .integer).notNull().defaults(to: 0)
      t.add(column: "location", .text)
      t.add(column: "timezone", .text)
      t.add(column: "isFollowing", .integer).notNull().defaults(to: 0)
      t.add(column: "notes", .text)
    }
  }

  // MARK: - v4_extend_venue_schema Migration

  migrator.registerMigration("v4_extend_venue_schema") { db in
    // Add comprehensive venue fields
    try db.alter(table: "venue") { t in
      t.add(column: "description", .text)
      t.add(column: "building", .text)
      t.add(column: "roomNumber", .text)
      t.add(column: "seatingArrangement", .text)
      t.add(column: "hasStandingRoom", .integer).notNull().defaults(to: 0)
      t.add(column: "isWheelchairAccessible", .integer).notNull().defaults(to: 0)
      t.add(column: "accessibilityNotes", .text)
      t.add(column: "equipment", .text)  // JSON array
      t.add(column: "wifiNetwork", .text)
      t.add(column: "hasLiveStream", .integer).notNull().defaults(to: 0)
      t.add(column: "liveStreamURL", .text)
      t.add(column: "address", .text)
      t.add(column: "coordinates", .text)  // JSON or "lat,lng"
      t.add(column: "directions", .text)
      t.add(column: "isVirtual", .integer).notNull().defaults(to: 0)
      t.add(column: "virtualPlatform", .text)
      t.add(column: "virtualMeetingURL", .text)
      t.add(column: "virtualMeetingId", .text)
      t.add(column: "notes", .text)
      t.add(column: "isFavorited", .integer).notNull().defaults(to: 0)
    }
  }

  // MARK: - v5_extend_conference_schema Migration

  migrator.registerMigration("v5_extend_conference_schema") { db in
    // Add comprehensive conference fields
    try db.alter(table: "conference") { t in
      t.add(column: "tagline", .text)
      t.add(column: "description", .text)
      t.add(column: "address", .text)
      t.add(column: "coordinates", .text)  // JSON or "lat,lng"
      t.add(column: "registrationURL", .text)
      t.add(column: "isVirtual", .integer).notNull().defaults(to: 0)
      t.add(column: "virtualPlatform", .text)
      t.add(column: "topics", .text)  // JSON array
      t.add(column: "maxAttendees", .integer)
      t.add(column: "isAttending", .integer).notNull().defaults(to: 0)
    }
  }

  // Run migrations
  try migrator.migrate(database)

  return database
}

/// Database manager for TechConf
public actor DatabaseManager {
  private let logger = Logger(label: "TechConfCore.DatabaseManager")
  private let database: any DatabaseWriter

  public init(database: any DatabaseWriter) {
    self.database = database
  }

  // MARK: - Database Operations

  /// Perform a read operation
  public func read<T: Sendable>(_ block: @Sendable @escaping (Database) throws -> T) async throws
    -> T
  {
    try await database.read { db in
      try block(db)
    }
  }

  /// Perform a write operation
  public func write<T: Sendable>(_ block: @Sendable @escaping (Database) throws -> T) async throws
    -> T
  {
    try await database.write { db in
      try block(db)
    }
  }

  // MARK: - Maintenance Operations

  /// Vacuum the database to reclaim space
  public func vacuum() async throws {
    logger.info("Vacuuming database")

    try await database.write { db in
      try db.execute(sql: "VACUUM")
    }

    logger.info("Database vacuum completed")
  }

  /// Get database statistics
  public func statistics() async throws -> DatabaseStatistics {
    try await database.read { db in
      let pageCount = try Int.fetchOne(db, sql: "PRAGMA page_count") ?? 0
      let pageSize = try Int.fetchOne(db, sql: "PRAGMA page_size") ?? 0
      let freeListCount = try Int.fetchOne(db, sql: "PRAGMA freelist_count") ?? 0

      let totalSize = pageCount * pageSize
      let freeSize = freeListCount * pageSize
      let usedSize = totalSize - freeSize

      // Count records
      let conferenceCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM conference") ?? 0
      let sessionCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM session") ?? 0
      let speakerCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM speaker") ?? 0
      let venueCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM venue") ?? 0

      return DatabaseStatistics(
        totalSizeBytes: totalSize,
        usedSizeBytes: usedSize,
        conferenceCount: conferenceCount,
        sessionCount: sessionCount,
        speakerCount: speakerCount,
        venueCount: venueCount
      )
    }
  }

  /// Check database integrity
  public func checkIntegrity() async throws -> Bool {
    logger.info("Checking database integrity")

    let result = try await database.read { db -> String in
      try String.fetchOne(db, sql: "PRAGMA integrity_check") ?? "error"
    }

    let isValid = result == "ok"
    if isValid {
      logger.info("Database integrity check passed")
    } else {
      logger.error("Database integrity check failed: \(result)")
    }

    return isValid
  }
}

// MARK: - Supporting Types

public struct DatabaseStatistics: Sendable {
  public let totalSizeBytes: Int
  public let usedSizeBytes: Int
  public let conferenceCount: Int
  public let sessionCount: Int
  public let speakerCount: Int
  public let venueCount: Int

  public var totalSizeMB: Double {
    Double(totalSizeBytes) / 1_048_576
  }

  public var usedSizeMB: Double {
    Double(usedSizeBytes) / 1_048_576
  }

  public var freeSizeMB: Double {
    Double(totalSizeBytes - usedSizeBytes) / 1_048_576
  }
}

public enum DatabaseError: LocalizedError {
  case invalidPath(String)
  case migrationFailed(String)
  case integrityCheckFailed

  public var errorDescription: String? {
    switch self {
    case .invalidPath(let path):
      return "Invalid database path: \(path)"
    case .migrationFailed(let details):
      return "Database migration failed: \(details)"
    case .integrityCheckFailed:
      return "Database integrity check failed"
    }
  }
}
