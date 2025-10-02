import Foundation
import GRDB

/// Main query model for TechConf data access
///
/// Provides a repository pattern for querying conference-related data
/// with proper filtering, ordering, and error handling.
public struct ConferenceQueries: Sendable {
    private let database: DatabaseManager

    public init(database: DatabaseManager) {
        self.database = database
    }

    // MARK: - Session Queries

    /// List sessions with optional filtering
    ///
    /// - Parameters:
    ///   - conferenceId: Filter by conference
    ///   - track: Filter by track name
    ///   - day: Filter by date (start of day to end of day)
    ///   - speakerId: Filter by speaker
    ///   - difficultyLevel: Filter by difficulty level
    ///   - format: Filter by session format
    /// - Returns: Array of filtered sessions ordered by start time
    public func listSessions(
        conferenceId: UUID? = nil,
        track: String? = nil,
        day: Date? = nil,
        speakerId: UUID? = nil,
        difficultyLevel: DifficultyLevel? = nil,
        format: SessionFormat? = nil
    ) async throws -> [Session] {
        try await database.read { db in
            var sql = "SELECT * FROM session WHERE 1=1"
            var arguments: [DatabaseValueConvertible] = []

            if let conferenceId = conferenceId {
                sql += " AND conferenceId = ?"
                arguments.append(conferenceId.uuidString)
            }

            if let track = track {
                sql += " AND track = ?"
                arguments.append(track)
            }

            if let day = day {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: day)
                guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
                    throw QueryError.invalidDateRange
                }

                sql += " AND startTime >= ? AND startTime < ?"
                arguments.append(startOfDay)
                arguments.append(endOfDay)
            }

            if let speakerId = speakerId {
                // Search in JSON array - SQLite JSON1 extension
                sql += " AND speakerIds LIKE ?"
                arguments.append("%\(speakerId.uuidString)%")
            }

            if let difficultyLevel = difficultyLevel {
                sql += " AND difficultyLevel = ?"
                arguments.append(difficultyLevel.rawValue)
            }

            if let format = format {
                sql += " AND format = ?"
                arguments.append(format.rawValue)
            }

            sql += " ORDER BY startTime ASC"

            let rows = try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            return rows.compactMap { try? Session(row: $0) }
        }
    }

    /// Search sessions by title or description
    ///
    /// - Parameters:
    ///   - query: Search term to match against title and description
    ///   - limit: Maximum number of results
    /// - Returns: Array of matching sessions ordered by relevance (exact title matches first)
    public func searchSessions(
        query: String,
        limit: Int = 50
    ) async throws -> [Session] {
        try await database.read { db in
            let searchPattern = "%\(query)%"

            let sql = """
                SELECT *,
                    CASE
                        WHEN title LIKE ? THEN 1
                        WHEN description LIKE ? THEN 2
                        ELSE 3
                    END as relevance
                FROM session
                WHERE title LIKE ? OR description LIKE ?
                ORDER BY relevance ASC, startTime ASC
                LIMIT ?
                """

            let rows = try Row.fetchAll(
                db,
                sql: sql,
                arguments: [searchPattern, searchPattern, searchPattern, searchPattern, limit]
            )

            return rows.compactMap { try? Session(row: $0) }
        }
    }

    /// Get a specific session by ID
    ///
    /// - Parameter id: Session identifier
    /// - Returns: Session if found, nil otherwise
    public func getSession(id: UUID) async throws -> Session? {
        try await database.read { db in
            let sql = "SELECT * FROM session WHERE id = ?"
            guard let row = try Row.fetchOne(db, sql: sql, arguments: [id.uuidString]) else {
                return nil
            }
            return try? Session(row: row)
        }
    }

    /// Get all sessions for a specific speaker
    ///
    /// - Parameter speakerId: Speaker identifier
    /// - Returns: Array of sessions ordered by start time
    public func getSessionsForSpeaker(speakerId: UUID) async throws -> [Session] {
        try await database.read { db in
            let sql = """
                SELECT * FROM session
                WHERE speakerIds LIKE ?
                ORDER BY startTime ASC
                """

            let searchPattern = "%\(speakerId.uuidString)%"
            let rows = try Row.fetchAll(db, sql: sql, arguments: [searchPattern])
            return rows.compactMap { try? Session(row: $0) }
        }
    }

    /// Get all sessions for a specific venue
    ///
    /// - Parameter venueId: Venue identifier
    /// - Returns: Array of sessions ordered by start time
    public func getSessionsForVenue(venueId: UUID) async throws -> [Session] {
        try await database.read { db in
            let sql = """
                SELECT * FROM session
                WHERE venueId = ?
                ORDER BY startTime ASC
                """

            let rows = try Row.fetchAll(db, sql: sql, arguments: [venueId.uuidString])
            return rows.compactMap { try? Session(row: $0) }
        }
    }

    // MARK: - Speaker Queries

    /// Get a specific speaker by ID
    ///
    /// - Parameter id: Speaker identifier
    /// - Returns: Speaker if found, nil otherwise
    public func getSpeaker(id: UUID) async throws -> Speaker? {
        try await database.read { db in
            let sql = "SELECT * FROM speaker WHERE id = ?"
            guard let row = try Row.fetchOne(db, sql: sql, arguments: [id.uuidString]) else {
                return nil
            }
            return try? Speaker(row: row)
        }
    }

    /// Find speakers by name
    ///
    /// - Parameter name: Name or partial name to search for
    /// - Returns: Array of matching speakers ordered by name
    public func findSpeakers(name: String) async throws -> [Speaker] {
        try await database.read { db in
            let searchPattern = "%\(name)%"
            let sql = """
                SELECT * FROM speaker
                WHERE name LIKE ?
                ORDER BY name ASC
                """

            let rows = try Row.fetchAll(db, sql: sql, arguments: [searchPattern])
            return rows.compactMap { try? Speaker(row: $0) }
        }
    }

    /// List all speakers for a conference
    ///
    /// - Parameter conferenceId: Conference identifier
    /// - Returns: Array of speakers ordered by name
    public func listSpeakers(conferenceId: UUID) async throws -> [Speaker] {
        try await database.read { db in
            let sql = """
                SELECT DISTINCT speaker.*
                FROM speaker
                INNER JOIN session ON session.speakerIds LIKE '%' || speaker.id || '%'
                WHERE session.conferenceId = ?
                ORDER BY speaker.name ASC
                """

            let rows = try Row.fetchAll(db, sql: sql, arguments: [conferenceId.uuidString])
            return rows.compactMap { try? Speaker(row: $0) }
        }
    }

    // MARK: - Venue Queries

    /// Get a specific venue by ID
    ///
    /// - Parameter id: Venue identifier
    /// - Returns: Venue if found, nil otherwise
    public func getVenue(id: UUID) async throws -> Venue? {
        try await database.read { db in
            let sql = "SELECT * FROM venue WHERE id = ?"
            guard let row = try Row.fetchOne(db, sql: sql, arguments: [id.uuidString]) else {
                return nil
            }
            return try? Venue(row: row)
        }
    }

    /// Find a venue by exact name match
    ///
    /// - Parameter name: Exact venue name
    /// - Returns: Venue if found, nil otherwise
    public func findVenue(name: String) async throws -> Venue? {
        try await database.read { db in
            let sql = """
                SELECT * FROM venue
                WHERE name = ?
                LIMIT 1
                """

            guard let row = try Row.fetchOne(db, sql: sql, arguments: [name]) else {
                return nil
            }
            return try? Venue(row: row)
        }
    }

    /// List all venues for a conference
    ///
    /// - Parameter conferenceId: Conference identifier
    /// - Returns: Array of venues ordered by name
    public func listVenues(conferenceId: UUID) async throws -> [Venue] {
        try await database.read { db in
            let sql = """
                SELECT * FROM venue
                WHERE conferenceId = ?
                ORDER BY name ASC
                """

            let rows = try Row.fetchAll(db, sql: sql, arguments: [conferenceId.uuidString])
            return rows.compactMap { try? Venue(row: $0) }
        }
    }

    // MARK: - Schedule Queries

    /// Get all sessions for a specific day
    ///
    /// - Parameters:
    ///   - date: The date to get sessions for
    ///   - conferenceId: Optional conference filter
    /// - Returns: Array of sessions ordered by start time
    public func getScheduleForDay(
        date: Date,
        conferenceId: UUID? = nil
    ) async throws -> [Session] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw QueryError.invalidDateRange
        }

        return try await getScheduleForTimeRange(
            start: startOfDay,
            end: endOfDay,
            conferenceId: conferenceId
        )
    }

    /// Get all sessions within a time range
    ///
    /// - Parameters:
    ///   - start: Start of time range
    ///   - end: End of time range
    ///   - conferenceId: Optional conference filter
    /// - Returns: Array of sessions ordered by start time
    public func getScheduleForTimeRange(
        start: Date,
        end: Date,
        conferenceId: UUID? = nil
    ) async throws -> [Session] {
        try await database.read { db in
            var sql = """
                SELECT * FROM session
                WHERE (startTime >= ? AND startTime < ?)
                   OR (endTime > ? AND endTime <= ?)
                   OR (startTime <= ? AND endTime >= ?)
                """

            var arguments: [DatabaseValueConvertible] = [
                start, end,  // Session starts in range
                start, end,  // Session ends in range
                start, end   // Session spans entire range
            ]

            if let conferenceId = conferenceId {
                sql += " AND conferenceId = ?"
                arguments.append(conferenceId.uuidString)
            }

            sql += " ORDER BY startTime ASC"

            let rows = try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            return rows.compactMap { try? Session(row: $0) }
        }
    }

    // MARK: - Conference Queries

    /// Get a specific conference by ID
    ///
    /// - Parameter id: Conference identifier
    /// - Returns: Conference if found, nil otherwise
    public func getConference(id: UUID) async throws -> Conference? {
        try await database.read { db in
            let sql = "SELECT * FROM conference WHERE id = ?"
            guard let row = try Row.fetchOne(db, sql: sql, arguments: [id.uuidString]) else {
                return nil
            }
            return try? Conference(row: row)
        }
    }

    /// List all conferences with optional filters
    ///
    /// - Parameters:
    ///   - upcoming: If true, only upcoming conferences; if false, only past
    ///   - isAttending: Filter by attendance status
    ///   - limit: Maximum number of results
    /// - Returns: Array of conferences ordered by start date
    public func listConferences(
        upcoming: Bool? = nil,
        isAttending: Bool? = nil,
        limit: Int = 100
    ) async throws -> [Conference] {
        try await database.read { db in
            var sql = "SELECT * FROM conference WHERE 1=1"
            var arguments: [DatabaseValueConvertible] = []

            if let upcoming = upcoming {
                let now = Date()
                if upcoming {
                    sql += " AND startDate > ?"
                } else {
                    sql += " AND endDate < ?"
                }
                arguments.append(now)
            }

            if let isAttending = isAttending {
                sql += " AND isAttending = ?"
                arguments.append(isAttending ? 1 : 0)
            }

            sql += " ORDER BY startDate DESC LIMIT ?"
            arguments.append(limit)

            let rows = try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            return rows.compactMap { try? Conference(row: $0) }
        }
    }

    // MARK: - Advanced Queries

    /// Get sessions that are currently happening
    ///
    /// - Parameter conferenceId: Optional conference filter
    /// - Returns: Array of ongoing sessions
    public func getOngoingSessions(conferenceId: UUID? = nil) async throws -> [Session] {
        let now = Date()

        return try await database.read { db in
            var sql = """
                SELECT * FROM session
                WHERE startTime <= ? AND endTime >= ?
                """

            var arguments: [DatabaseValueConvertible] = [now, now]

            if let conferenceId = conferenceId {
                sql += " AND conferenceId = ?"
                arguments.append(conferenceId.uuidString)
            }

            sql += " ORDER BY startTime ASC"

            let rows = try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            return rows.compactMap { try? Session(row: $0) }
        }
    }

    /// Get user's favorited sessions
    ///
    /// - Parameter conferenceId: Optional conference filter
    /// - Returns: Array of favorited sessions ordered by start time
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

    /// Get sessions by track
    ///
    /// - Parameters:
    ///   - track: Track name
    ///   - conferenceId: Conference identifier
    /// - Returns: Array of sessions in the track ordered by start time
    public func getSessionsByTrack(
        track: String,
        conferenceId: UUID
    ) async throws -> [Session] {
        try await listSessions(conferenceId: conferenceId, track: track)
    }

    /// Get all unique tracks for a conference
    ///
    /// - Parameter conferenceId: Conference identifier
    /// - Returns: Array of unique track names
    public func getTracksForConference(conferenceId: UUID) async throws -> [String] {
        try await database.read { db in
            let sql = """
                SELECT DISTINCT track
                FROM session
                WHERE conferenceId = ? AND track IS NOT NULL
                ORDER BY track ASC
                """

            return try String.fetchAll(db, sql: sql, arguments: [conferenceId.uuidString])
        }
    }
}

// MARK: - Supporting Types

/// Query errors
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

// MARK: - Row Decoding Extensions

extension Session {
    public init(row: Row) throws {
        self.init(
            id: UUID(uuidString: row["id"]) ?? UUID(),
            conferenceId: UUID(uuidString: row["conferenceId"]) ?? UUID(),
            venueId: (row["venueId"] as? String).flatMap { UUID(uuidString: $0) },
            speakerIds: row["speakerIds"],
            title: row["title"],
            description: row["description"],
            abstract: row["abstract"],
            format: SessionFormat(rawValue: row["format"]) ?? .talk,
            difficultyLevel: DifficultyLevel(rawValue: row["difficultyLevel"]) ?? .all,
            track: row["track"],
            tags: row["tags"],
            startTime: row["startTime"],
            endTime: row["endTime"],
            durationMinutes: row["durationMinutes"],
            capacity: row["capacity"],
            isRecorded: (row["isRecorded"] as? Int) == 1,
            recordingURL: row["recordingURL"],
            slidesURL: row["slidesURL"],
            isFavorited: (row["isFavorited"] as? Int) == 1,
            didAttend: (row["didAttend"] as? Int) == 1,
            notes: row["notes"],
            rating: row["rating"],
            createdAt: row["createdAt"]
        )
    }
}

extension Speaker {
    public init(row: Row) throws {
        self.init(
            id: UUID(uuidString: row["id"]) ?? UUID(),
            name: row["name"],
            title: row["title"],
            company: row["company"],
            bio: row["bio"],
            shortBio: row["shortBio"],
            email: row["email"],
            socialLinks: row["socialLinks"],
            websiteURL: row["websiteURL"],
            photoURL: row["photoURL"],
            expertise: row["expertise"],
            previousConferences: row["previousConferences"],
            yearsExperience: row["yearsExperience"],
            isKeynoteSpeaker: (row["isKeynoteSpeaker"] as? Int) == 1,
            location: row["location"],
            timezone: row["timezone"],
            isFollowing: (row["isFollowing"] as? Int) == 1,
            notes: row["notes"],
            createdAt: row["createdAt"],
            updatedAt: row["updatedAt"]
        )
    }
}

extension Venue {
    public init(row: Row) throws {
        self.init(
            id: UUID(uuidString: row["id"]) ?? UUID(),
            conferenceId: UUID(uuidString: row["conferenceId"]) ?? UUID(),
            name: row["name"],
            description: row["description"],
            building: row["building"],
            floor: row["floor"],
            roomNumber: row["roomNumber"],
            capacity: row["capacity"],
            seatingArrangement: row["seatingArrangement"],
            hasStandingRoom: (row["hasStandingRoom"] as? Int) == 1,
            accessibility: row["accessibility"],
            isWheelchairAccessible: (row["isWheelchairAccessible"] as? Int) == 1,
            accessibilityNotes: row["accessibilityNotes"],
            equipment: row["equipment"],
            wifiNetwork: row["wifiNetwork"],
            hasLiveStream: (row["hasLiveStream"] as? Int) == 1,
            liveStreamURL: row["liveStreamURL"],
            address: row["address"],
            coordinates: row["coordinates"],
            directions: row["directions"],
            isVirtual: (row["isVirtual"] as? Int) == 1,
            virtualPlatform: row["virtualPlatform"],
            virtualMeetingURL: row["virtualMeetingURL"],
            virtualMeetingId: row["virtualMeetingId"],
            notes: row["notes"],
            isFavorited: (row["isFavorited"] as? Int) == 1,
            createdAt: row["createdAt"]
        )
    }
}

extension Conference {
    public init(row: Row) throws {
        self.init(
            id: UUID(uuidString: row["id"]) ?? UUID(),
            name: row["name"],
            tagline: row["tagline"],
            description: row["description"],
            startDate: row["startDate"],
            endDate: row["endDate"],
            timezone: row["timezone"],
            location: row["location"],
            address: row["address"],
            coordinates: row["coordinates"],
            website: row["website"],
            registrationURL: row["registrationURL"],
            isVirtual: (row["isVirtual"] as? Int) == 1,
            virtualPlatform: row["virtualPlatform"],
            topics: row["topics"],
            maxAttendees: row["maxAttendees"],
            createdAt: row["createdAt"],
            isAttending: (row["isAttending"] as? Int) == 1
        )
    }
}
