import Foundation
import GRDB
import Logging

/// JSON structures matching the conference data file format
private struct ConferenceJSON: Codable {
  let conference: ConferenceDataJSON
  let speakers: [SpeakerJSON]
  let sessions: [SessionJSON]
  let venues: [VenueJSON]
}

private struct ConferenceDataJSON: Codable {
  let id: String
  let name: String
  let shortName: String?
  let description: String?
  let startDate: String
  let endDate: String
  let timezone: String
  let location: LocationJSON?
  let website: String?
  let hashtag: String?

  struct LocationJSON: Codable {
    let city: String?
    let state: String?
    let country: String?
    let venue: String?
    let address: String?
  }
}

private struct SpeakerJSON: Codable {
  let id: String
  let name: String
  let title: String?
  let company: String?
  let bio: String?
  let expertise: [String]?
  let avatar: String?
  let social: SocialJSON?

  struct SocialJSON: Codable {
    let twitter: String?
    let github: String?
    let linkedin: String?
    let mastodon: String?
    let website: String?
  }
}

private struct SessionJSON: Codable {
  let id: String
  let title: String
  let type: String?  // maps to format
  let track: String?
  let difficulty: String?  // maps to difficultyLevel
  let description: String?
  let abstract: String?
  let learningOutcomes: [String]?
  let startTime: String
  let endTime: String
  let venueId: String?
  let speakerIds: [String]?
  let tags: [String]?
  let level: String?
  let recordingAvailable: Bool?
  let capacity: Int?
}

private struct VenueJSON: Codable {
  let id: String
  let name: String
  let capacity: Int?
  let floor: String?
  let building: String?
  let type: String?
  let equipment: [String]?
  let accessibility: [String: Bool]?
}

/// Imports conference data from JSON files into the database
public actor DataImporter {
  private let database: DatabaseManager
  private let logger: Logger

  public init(database: DatabaseManager, logger: Logger) {
    self.database = database
    self.logger = logger
  }

  /// Import bundled ServerSide.swift 2025 conference data
  public func importBundledConferenceData() async throws {
    // Try installed data location first
    let installedPath = NSHomeDirectory() + "/.tech-conf-mcp/data/serverside-swift-2025.json"
    let jsonURL: URL

    if FileManager.default.fileExists(atPath: installedPath) {
      jsonURL = URL(fileURLWithPath: installedPath)
      logger.info("Loading conference data from installed location")
    } else if let bundleURL = Bundle.module.url(
      forResource: "serverside-swift-2025",
      withExtension: "json",
      subdirectory: "Resources/Conferences"
    ) {
      jsonURL = bundleURL
      logger.info("Loading conference data from bundle")
    } else {
      throw DataImportError.invalidJSON(
        "Conference data file not found. Expected at: \(installedPath)"
      )
    }

    let jsonData = try Data(contentsOf: jsonURL)
    try await importConference(from: jsonData)
  }

  /// Import conference data from a JSON file
  public func importConference(from jsonData: Data) async throws {
    logger.info("Starting data import")

    // Decode JSON
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let conferenceData = try decoder.decode(ConferenceJSON.self, from: jsonData)

    logger.info("Decoded JSON data", metadata: [
      "speakers": "\(conferenceData.speakers.count)",
      "sessions": "\(conferenceData.sessions.count)",
      "venues": "\(conferenceData.venues.count)",
    ])

    // Import in order: conference -> speakers -> venues -> sessions
    // Maintain ID mappings for relationships
    let conferenceId = try await importConferenceData(conferenceData.conference)
    let speakerIdMap = try await importSpeakers(conferenceData.speakers)
    let venueIdMap = try await importVenues(conferenceData.venues, conferenceId: conferenceId)
    try await importSessions(
      conferenceData.sessions,
      conferenceId: conferenceId,
      speakerIdMap: speakerIdMap,
      venueIdMap: venueIdMap
    )

    logger.info("Data import completed successfully")
  }

  /// Check if the database already has data
  public func hasData() async throws -> Bool {
    try await database.read { db in
      let count = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM conference")
      return (count ?? 0) > 0
    }
  }

  // MARK: - Private Import Methods

  private func importConferenceData(_ data: ConferenceDataJSON) async throws -> UUID {
    logger.info("Importing conference data")

    let conferenceId = UUID()
    let dateFormatter = ISO8601DateFormatter()

    guard let startDate = dateFormatter.date(from: data.startDate),
      let endDate = dateFormatter.date(from: data.endDate)
    else {
      throw DataImportError.invalidDate("Unable to parse conference dates")
    }

    let locationString: String? =
      if let location = data.location {
        [location.city, location.state, location.country]
          .compactMap { $0 }
          .joined(separator: ", ")
      } else {
        nil
      }

    // Insert conference using raw SQL to match exact database schema
    try await database.write { db in
      try db.execute(
        sql: """
          INSERT INTO conference (id, name, startDate, endDate, location, timezone, website, createdAt, updatedAt)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          """,
        arguments: [
          conferenceId.uuidString,
          data.name,
          ISO8601DateFormatter().string(from: startDate),
          ISO8601DateFormatter().string(from: endDate),
          locationString,
          data.timezone,
          data.website,
          ISO8601DateFormatter().string(from: Date()),
          ISO8601DateFormatter().string(from: Date()),
        ]
      )
    }

    logger.info("Imported conference", metadata: ["id": "\(conferenceId)", "name": "\(data.name)"])
    return conferenceId
  }

  private func importSpeakers(_ speakers: [SpeakerJSON]) async throws -> [String: UUID] {
    logger.info("Importing speakers", metadata: ["count": "\(speakers.count)"])

    var idMap: [String: UUID] = [:]

    for speakerData in speakers {
      let speakerId = UUID()
      idMap[speakerData.id] = speakerId

      // Convert social links to JSON string
      var socialLinks: [String: String] = [:]
      if let social = speakerData.social {
        if let twitter = social.twitter { socialLinks["twitter"] = twitter }
        if let github = social.github { socialLinks["github"] = github }
        if let linkedin = social.linkedin { socialLinks["linkedin"] = linkedin }
        if let mastodon = social.mastodon { socialLinks["mastodon"] = mastodon }
        if let website = social.website { socialLinks["website"] = website }
      }

      let socialLinksJSON =
        try? String(
          data: JSONEncoder().encode(socialLinks),
          encoding: .utf8
        )

      // Convert expertise array to JSON string
      let expertiseJSON: String? =
        if let expertise = speakerData.expertise {
          try? String(data: JSONEncoder().encode(expertise), encoding: .utf8)
        } else {
          nil
        }

      // Insert speaker using raw SQL to match exact database schema
      // Schema has: id, name, bio, company, twitter, website, createdAt, updatedAt
      try await database.write { db in
        try db.execute(
          sql: """
            INSERT INTO speaker (id, name, bio, company, twitter, website, createdAt, updatedAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
          arguments: [
            speakerId.uuidString,
            speakerData.name,
            speakerData.bio,
            speakerData.company,
            speakerData.social?.twitter,
            speakerData.social?.website,
            ISO8601DateFormatter().string(from: Date()),
            ISO8601DateFormatter().string(from: Date()),
          ]
        )
      }
    }

    logger.info("Imported speakers successfully")
    return idMap
  }

  private func importVenues(_ venues: [VenueJSON], conferenceId: UUID) async throws -> [String: UUID]
  {
    logger.info("Importing venues", metadata: ["count": "\(venues.count)"])

    var idMap: [String: UUID] = [:]

    for venueData in venues {
      let venueId = UUID()
      idMap[venueData.id] = venueId

      // Convert accessibility dictionary to JSON string
      let accessibilityJSON: String? =
        if let accessibility = venueData.accessibility {
          try? String(data: JSONEncoder().encode(accessibility), encoding: .utf8)
        } else {
          nil
        }

      // Insert venue using raw SQL to match exact database schema
      // Schema has: id, conferenceId, name, capacity, floor, accessibility, createdAt, updatedAt
      try await database.write { db in
        try db.execute(
          sql: """
            INSERT INTO venue (id, conferenceId, name, capacity, floor, accessibility, createdAt, updatedAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
          arguments: [
            venueId.uuidString,
            conferenceId.uuidString,
            venueData.name,
            venueData.capacity,
            venueData.floor,
            accessibilityJSON,
            ISO8601DateFormatter().string(from: Date()),
            ISO8601DateFormatter().string(from: Date()),
          ]
        )
      }
    }

    logger.info("Imported venues successfully")
    return idMap
  }

  private func importSessions(
    _ sessions: [SessionJSON],
    conferenceId: UUID,
    speakerIdMap: [String: UUID],
    venueIdMap: [String: UUID]
  ) async throws {
    logger.info("Importing sessions", metadata: ["count": "\(sessions.count)"])

    let dateFormatter = ISO8601DateFormatter()

    for sessionData in sessions {
      let sessionId = UUID()

      guard let startTime = dateFormatter.date(from: sessionData.startTime),
        let endTime = dateFormatter.date(from: sessionData.endTime)
      else {
        logger.warning("Skipping session with invalid dates", metadata: [
          "sessionId": "\(sessionData.id)", "title": "\(sessionData.title)",
        ])
        continue
      }

      // Map venue ID from JSON to database UUID
      let venueId: UUID? =
        if let venueIdStr = sessionData.venueId {
          venueIdMap[venueIdStr]
        } else {
          nil
        }

      // Map speaker IDs from JSON to database UUIDs
      let speakerIdsJSON: String?
      if let speakerIds = sessionData.speakerIds {
        let uuids = speakerIds.compactMap { speakerIdMap[$0] }
        if !uuids.isEmpty {
          speakerIdsJSON = try? String(
            data: JSONEncoder().encode(uuids.map { $0.uuidString }),
            encoding: .utf8
          )
        } else {
          speakerIdsJSON = nil
        }
      } else {
        speakerIdsJSON = nil
      }

      // Convert tags array to JSON string
      let tagsJSON: String? =
        if let tags = sessionData.tags {
          try? String(data: JSONEncoder().encode(tags), encoding: .utf8)
        } else {
          nil
        }

      // Map format (type in JSON)
      let format = sessionData.type ?? "talk"

      // Map difficulty level
      let difficultyLevel = sessionData.difficulty ?? sessionData.level ?? "all"

      // Get speaker ID (use first speaker if multiple - schema has single speakerId field)
      let speakerId: UUID? =
        if let speakerIds = sessionData.speakerIds, !speakerIds.isEmpty {
          speakerIdMap[speakerIds[0]]
        } else {
          nil
        }

      // Insert session using raw SQL to match exact database schema
      // Schema has: id, conferenceId, title, description, speakerId, startTime, endTime, venueId, track, format, difficultyLevel, tags, createdAt, updatedAt
      try await database.write { db in
        try db.execute(
          sql: """
            INSERT INTO session (id, conferenceId, title, description, speakerId, startTime, endTime, venueId, track, format, difficultyLevel, tags, createdAt, updatedAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
          arguments: [
            sessionId.uuidString,
            conferenceId.uuidString,
            sessionData.title,
            sessionData.description,
            speakerId?.uuidString,
            ISO8601DateFormatter().string(from: startTime),
            ISO8601DateFormatter().string(from: endTime),
            venueId?.uuidString,
            sessionData.track,
            format,
            difficultyLevel,
            tagsJSON,
            ISO8601DateFormatter().string(from: Date()),
            ISO8601DateFormatter().string(from: Date()),
          ]
        )
      }
    }

    logger.info("Imported sessions successfully")
  }
}

// MARK: - Errors

public enum DataImportError: LocalizedError {
  case invalidDate(String)
  case invalidJSON(String)

  public var errorDescription: String? {
    switch self {
    case .invalidDate(let message):
      return "Invalid date: \(message)"
    case .invalidJSON(let message):
      return "Invalid JSON: \(message)"
    }
  }
}
