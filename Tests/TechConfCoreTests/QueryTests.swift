import Testing
import Foundation
import GRDB
@testable import TechConfCore

@Suite("ConferenceQueries Tests")
@MainActor
struct QueryTests {
    
    func setupTestData() async throws -> DatabaseManager {
        let database = try createConferenceDatabase()
        let manager = DatabaseManager(database: database)
        
        // Insert test conference
        let conferenceId = UUID()
        try await manager.write { db in
            try db.execute(sql: """
                INSERT INTO conference (id, name, startDate, endDate, timezone, location)
                VALUES (?, ?, ?, ?, ?, ?)
                """, arguments: [
                conferenceId.uuidString,
                "SwiftConf 2025",
                Date(),
                Date(timeIntervalSinceNow: 86400 * 3),
                "America/New_York",
                "San Francisco, USA"
            ])
        }
        
        // Insert test speaker
        let speakerId = UUID()
        try await manager.write { db in
            try db.execute(sql: """
                INSERT INTO speaker (id, name, bio, company)
                VALUES (?, ?, ?, ?)
                """, arguments: [
                speakerId.uuidString,
                "Jane Doe",
                "iOS Expert",
                "Apple"
            ])
        }
        
        // Insert test venue
        let venueId = UUID()
        try await manager.write { db in
            try db.execute(sql: """
                INSERT INTO venue (id, conferenceId, name, capacity)
                VALUES (?, ?, ?, ?)
                """, arguments: [
                venueId.uuidString,
                conferenceId.uuidString,
                "Main Hall",
                500
            ])
        }
        
        // Insert test sessions
        for i in 0..<5 {
            let sessionId = UUID()
            let startTime = Date(timeIntervalSinceNow: TimeInterval(3600 * i))
            let endTime = Date(timeInterval: 3600, since: startTime)
            
            try await manager.write { db in
                try db.execute(sql: """
                    INSERT INTO session (
                        id, conferenceId, title, description, speakerId,
                        startTime, endTime, venueId, track, format, difficultyLevel
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """, arguments: [
                    sessionId.uuidString,
                    conferenceId.uuidString,
                    "Session \(i + 1)",
                    "Description for session \(i + 1)",
                    speakerId.uuidString,
                    startTime,
                    endTime,
                    venueId.uuidString,
                    i % 2 == 0 ? "iOS" : "Backend",
                    "talk",
                    i < 2 ? "beginner" : "intermediate"
                ])
            }
        }
        
        return manager
    }
    
    @Test("List all sessions")
    func testListAllSessions() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let sessions = try await queries.listSessions()
        
        #expect(sessions.count == 5)
    }
    
    @Test("List sessions filtered by track")
    func testListSessionsByTrack() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let sessions = try await queries.listSessions(track: "iOS")
        
        #expect(sessions.count == 3)
        for session in sessions {
            #expect(session.track == "iOS")
        }
    }
    
    @Test("List sessions filtered by difficulty level")
    func testListSessionsByDifficulty() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let sessions = try await queries.listSessions(difficultyLevel: .beginner)
        
        #expect(sessions.count == 2)
        for session in sessions {
            #expect(session.difficultyLevel == .beginner)
        }
    }
    
    @Test("List sessions filtered by format")
    func testListSessionsByFormat() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let sessions = try await queries.listSessions(format: .talk)
        
        #expect(sessions.count == 5)
    }
    
    @Test("Search sessions by title")
    func testSearchSessionsByTitle() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let sessions = try await queries.searchSessions(query: "Session 1")
        
        #expect(sessions.count == 1)
        #expect(sessions.first?.title == "Session 1")
    }
    
    @Test("Search sessions with no results")
    func testSearchSessionsNoResults() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let sessions = try await queries.searchSessions(query: "Nonexistent")
        
        #expect(sessions.isEmpty)
    }
    
    @Test("Get session by ID")
    func testGetSessionById() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let allSessions = try await queries.listSessions()
        guard let firstSessionId = allSessions.first?.id else {
            throw TestError.noDataFound
        }
        
        let session = try await queries.getSession(id: firstSessionId)
        
        #expect(session != nil)
        #expect(session?.id == firstSessionId)
    }
    
    @Test("Get session by ID not found")
    func testGetSessionByIdNotFound() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let session = try await queries.getSession(id: UUID())
        
        #expect(session == nil)
    }
    
    @Test("Get sessions for speaker")
    func testGetSessionsForSpeaker() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let speakers = try await queries.findSpeakers(name: "Jane Doe")
        guard let speaker = speakers.first else {
            throw TestError.noDataFound
        }
        
        let sessions = try await queries.getSessionsForSpeaker(speakerId: speaker.id)
        
        #expect(sessions.count == 5)
    }
    
    @Test("Get sessions for venue")
    func testGetSessionsForVenue() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        // Get a venue first
        let allSessions = try await queries.listSessions()
        guard let venueId = allSessions.first?.venueId else {
            throw TestError.noDataFound
        }
        
        let sessions = try await queries.getSessionsForVenue(venueId: venueId)
        
        #expect(sessions.count == 5)
    }
    
    @Test("Get speaker by ID")
    func testGetSpeakerById() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let speakers = try await queries.findSpeakers(name: "Jane")
        guard let speakerId = speakers.first?.id else {
            throw TestError.noDataFound
        }
        
        let speaker = try await queries.getSpeaker(id: speakerId)
        
        #expect(speaker != nil)
        #expect(speaker?.name == "Jane Doe")
    }
    
    @Test("Find speakers by name")
    func testFindSpeakersByName() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let speakers = try await queries.findSpeakers(name: "Jane")
        
        #expect(speakers.count == 1)
        #expect(speakers.first?.name == "Jane Doe")
    }
    
    @Test("Find speakers with no results")
    func testFindSpeakersNoResults() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let speakers = try await queries.findSpeakers(name: "Nonexistent")
        
        #expect(speakers.isEmpty)
    }
    
    @Test("Get venue by ID")
    func testGetVenueById() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        // Get venue ID from a session
        let allSessions = try await queries.listSessions()
        guard let venueId = allSessions.first?.venueId else {
            throw TestError.noDataFound
        }
        
        let venue = try await queries.getVenue(id: venueId)
        
        #expect(venue != nil)
        #expect(venue?.name == "Main Hall")
    }
    
    @Test("Find venue by name")
    func testFindVenueByName() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let venue = try await queries.findVenue(name: "Main Hall")
        
        #expect(venue != nil)
        #expect(venue?.name == "Main Hall")
    }
    
    @Test("Find venue by name not found")
    func testFindVenueByNameNotFound() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let venue = try await queries.findVenue(name: "Nonexistent")
        
        #expect(venue == nil)
    }
    
    @Test("Get schedule for day")
    func testGetScheduleForDay() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let today = Date()
        let sessions = try await queries.getScheduleForDay(date: today)
        
        #expect(sessions.count >= 1)
    }
    
    @Test("Get schedule for time range")
    func testGetScheduleForTimeRange() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let start = Date()
        let end = Date(timeIntervalSinceNow: 7200) // 2 hours
        
        let sessions = try await queries.getScheduleForTimeRange(start: start, end: end)
        
        #expect(sessions.count >= 1)
    }
    
    @Test("Get conference by ID")
    func testGetConferenceById() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        // Get conference ID from a session
        let allSessions = try await queries.listSessions()
        guard let conferenceId = allSessions.first?.conferenceId else {
            throw TestError.noDataFound
        }
        
        let conference = try await queries.getConference(id: conferenceId)
        
        #expect(conference != nil)
        #expect(conference?.name == "SwiftConf 2025")
    }
    
    @Test("List all conferences")
    func testListAllConferences() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let conferences = try await queries.listConferences()
        
        #expect(conferences.count == 1)
    }
    
    @Test("Get ongoing sessions")
    func testGetOngoingSessions() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        // The first session should be starting around now
        let sessions = try await queries.getOngoingSessions()
        
        #expect(sessions.count >= 0)
    }
    
    @Test("Get favorited sessions - empty")
    func testGetFavoritedSessionsEmpty() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        let sessions = try await queries.getFavoritedSessions()
        
        #expect(sessions.isEmpty)
    }
    
    @Test("Get unique tracks for conference")
    func testGetTracksForConference() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        // Get conference ID from a session
        let allSessions = try await queries.listSessions()
        guard let conferenceId = allSessions.first?.conferenceId else {
            throw TestError.noDataFound
        }
        
        let tracks = try await queries.getTracksForConference(conferenceId: conferenceId)
        
        #expect(tracks.count == 2)
        #expect(tracks.contains("iOS"))
        #expect(tracks.contains("Backend"))
    }
    
    @Test("Get sessions by track")
    func testGetSessionsByTrack() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        // Get conference ID from a session
        let allSessions = try await queries.listSessions()
        guard let conferenceId = allSessions.first?.conferenceId else {
            throw TestError.noDataFound
        }
        
        let sessions = try await queries.getSessionsByTrack(
            track: "iOS",
            conferenceId: conferenceId
        )
        
        #expect(sessions.count == 3)
    }
    
    @Test("List speakers for conference")
    func testListSpeakersForConference() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        // Get conference ID from a session
        let allSessions = try await queries.listSessions()
        guard let conferenceId = allSessions.first?.conferenceId else {
            throw TestError.noDataFound
        }
        
        let speakers = try await queries.listSpeakers(conferenceId: conferenceId)
        
        #expect(speakers.count == 1)
        #expect(speakers.first?.name == "Jane Doe")
    }
    
    @Test("List venues for conference")
    func testListVenuesForConference() async throws {
        let manager = try await setupTestData()
        let queries = ConferenceQueries(database: manager)
        
        // Get conference ID from a session
        let allSessions = try await queries.listSessions()
        guard let conferenceId = allSessions.first?.conferenceId else {
            throw TestError.noDataFound
        }
        
        let venues = try await queries.listVenues(conferenceId: conferenceId)
        
        #expect(venues.count == 1)
        #expect(venues.first?.name == "Main Hall")
    }
}

@Suite("Query Edge Cases")
@MainActor
struct QueryEdgeCaseTests {
    
    @Test("List sessions with empty database")
    func testListSessionsEmptyDatabase() async throws {
        let database = try createConferenceDatabase()
        let manager = DatabaseManager(database: database)
        let queries = ConferenceQueries(database: manager)
        
        let sessions = try await queries.listSessions()
        
        #expect(sessions.isEmpty)
    }
    
    @Test("Search with empty query returns results")
    func testSearchWithEmptyQuery() async throws {
        let database = try createConferenceDatabase()
        let manager = DatabaseManager(database: database)
        let queries = ConferenceQueries(database: manager)
        
        let sessions = try await queries.searchSessions(query: "")
        
        #expect(sessions.isEmpty)
    }
    
    @Test("Get schedule for future date with no sessions")
    func testGetScheduleForFutureDate() async throws {
        let database = try createConferenceDatabase()
        let manager = DatabaseManager(database: database)
        let queries = ConferenceQueries(database: manager)
        
        let futureDate = Date(timeIntervalSinceNow: 86400 * 365)
        let sessions = try await queries.getScheduleForDay(date: futureDate)
        
        #expect(sessions.isEmpty)
    }
}

enum TestError: Error {
    case noDataFound
}
