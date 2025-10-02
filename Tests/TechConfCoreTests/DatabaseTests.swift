import Testing
import Foundation
import GRDB
@testable import TechConfCore

@Suite("Database Creation and Migration Tests")
struct DatabaseTests {
    
    @Test("Create in-memory database")
    func testCreateInMemoryDatabase() async throws {
        let database = try createConferenceDatabase()
        
        let count = try await database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM conference") ?? 0
        }
        
        #expect(count == 0)
    }
    
    @Test("Create file-based database")
    func testCreateFileBasedDatabase() async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let dbPath = tempDir.appendingPathComponent("test-\(UUID().uuidString).db").path
        
        let database = try createConferenceDatabase(at: dbPath)
        
        let count = try await database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM conference") ?? 0
        }
        
        #expect(count == 0)
        
        // Cleanup
        try? FileManager.default.removeItem(atPath: dbPath)
    }
    
    @Test("Database has conference table")
    func testConferenceTableExists() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let exists = try Bool.fetchOne(db, sql: """
                SELECT name FROM sqlite_master 
                WHERE type='table' AND name='conference'
                """) != nil
            #expect(exists)
        }
    }
    
    @Test("Database has speaker table")
    func testSpeakerTableExists() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let exists = try Bool.fetchOne(db, sql: """
                SELECT name FROM sqlite_master 
                WHERE type='table' AND name='speaker'
                """) != nil
            #expect(exists)
        }
    }
    
    @Test("Database has venue table")
    func testVenueTableExists() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let exists = try Bool.fetchOne(db, sql: """
                SELECT name FROM sqlite_master 
                WHERE type='table' AND name='venue'
                """) != nil
            #expect(exists)
        }
    }
    
    @Test("Database has session table")
    func testSessionTableExists() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let exists = try Bool.fetchOne(db, sql: """
                SELECT name FROM sqlite_master 
                WHERE type='table' AND name='session'
                """) != nil
            #expect(exists)
        }
    }
    
    @Test("Conference table has required columns")
    func testConferenceTableColumns() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(conference)")
            let columnNames = columns.compactMap { $0["name"] as? String }
            
            let requiredColumns = [
                "id", "name", "startDate", "endDate", "location", 
                "timezone", "website", "createdAt", "updatedAt"
            ]
            
            for column in requiredColumns {
                #expect(columnNames.contains(column), "Missing column: \(column)")
            }
        }
    }
    
    @Test("Speaker table has required columns")
    func testSpeakerTableColumns() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(speaker)")
            let columnNames = columns.compactMap { $0["name"] as? String }
            
            let requiredColumns = [
                "id", "name", "bio", "company", "twitter", 
                "website", "createdAt", "updatedAt"
            ]
            
            for column in requiredColumns {
                #expect(columnNames.contains(column), "Missing column: \(column)")
            }
        }
    }
    
    @Test("Session table has required columns")
    func testSessionTableColumns() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(session)")
            let columnNames = columns.compactMap { $0["name"] as? String }
            
            let requiredColumns = [
                "id", "conferenceId", "title", "description", "speakerId",
                "startTime", "endTime", "venueId", "track", "format",
                "difficultyLevel", "tags", "createdAt", "updatedAt"
            ]
            
            for column in requiredColumns {
                #expect(columnNames.contains(column), "Missing column: \(column)")
            }
        }
    }
    
    @Test("Venue table has required columns")
    func testVenueTableColumns() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(venue)")
            let columnNames = columns.compactMap { $0["name"] as? String }
            
            let requiredColumns = [
                "id", "conferenceId", "name", "capacity", "floor",
                "accessibility", "createdAt", "updatedAt"
            ]
            
            for column in requiredColumns {
                #expect(columnNames.contains(column), "Missing column: \(column)")
            }
        }
    }
    
    @Test("Conference dates index exists")
    func testConferenceDatesIndexExists() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let indexes = try Row.fetchAll(db, sql: """
                SELECT name FROM sqlite_master 
                WHERE type='index' AND tbl_name='conference'
                """)
            let indexNames = indexes.compactMap { $0["name"] as? String }
            
            #expect(indexNames.contains("idx_conference_dates"))
        }
    }
    
    @Test("Speaker name index exists")
    func testSpeakerNameIndexExists() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let indexes = try Row.fetchAll(db, sql: """
                SELECT name FROM sqlite_master 
                WHERE type='index' AND tbl_name='speaker'
                """)
            let indexNames = indexes.compactMap { $0["name"] as? String }
            
            #expect(indexNames.contains("idx_speaker_name"))
        }
    }
    
    @Test("Session indices exist")
    func testSessionIndicesExist() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let indexes = try Row.fetchAll(db, sql: """
                SELECT name FROM sqlite_master 
                WHERE type='index' AND tbl_name='session'
                """)
            let indexNames = indexes.compactMap { $0["name"] as? String }
            
            #expect(indexNames.contains("idx_session_conference"))
            #expect(indexNames.contains("idx_session_time"))
            #expect(indexNames.contains("idx_session_speaker"))
            #expect(indexNames.contains("idx_session_venue"))
            #expect(indexNames.contains("idx_session_track"))
        }
    }
    
    @Test("Venue conference index exists")
    func testVenueConferenceIndexExists() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let indexes = try Row.fetchAll(db, sql: """
                SELECT name FROM sqlite_master 
                WHERE type='index' AND tbl_name='venue'
                """)
            let indexNames = indexes.compactMap { $0["name"] as? String }
            
            #expect(indexNames.contains("idx_venue_conference"))
        }
    }
    
    @Test("Foreign keys are enabled")
    func testForeignKeysEnabled() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let fkEnabled = try Bool.fetchOne(db, sql: "PRAGMA foreign_keys") ?? false
            #expect(fkEnabled)
        }
    }
    
    @Test("Venue has foreign key to conference")
    func testVenueForeignKeyToConference() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let foreignKeys = try Row.fetchAll(db, sql: "PRAGMA foreign_key_list(venue)")
            
            let hasConferenceFk = foreignKeys.contains { row in
                row["table"] as? String == "conference" &&
                row["from"] as? String == "conferenceId"
            }
            
            #expect(hasConferenceFk)
        }
    }
    
    @Test("Session has foreign key to conference")
    func testSessionForeignKeyToConference() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let foreignKeys = try Row.fetchAll(db, sql: "PRAGMA foreign_key_list(session)")
            
            let hasConferenceFk = foreignKeys.contains { row in
                row["table"] as? String == "conference" &&
                row["from"] as? String == "conferenceId"
            }
            
            #expect(hasConferenceFk)
        }
    }
    
    @Test("Session has foreign key to speaker")
    func testSessionForeignKeyToSpeaker() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let foreignKeys = try Row.fetchAll(db, sql: "PRAGMA foreign_key_list(session)")
            
            let hasSpeakerFk = foreignKeys.contains { row in
                row["table"] as? String == "speaker" &&
                row["from"] as? String == "speakerId"
            }
            
            #expect(hasSpeakerFk)
        }
    }
    
    @Test("Session has foreign key to venue")
    func testSessionForeignKeyToVenue() async throws {
        let database = try createConferenceDatabase()
        
        try await database.read { db in
            let foreignKeys = try Row.fetchAll(db, sql: "PRAGMA foreign_key_list(session)")
            
            let hasVenueFk = foreignKeys.contains { row in
                row["table"] as? String == "venue" &&
                row["from"] as? String == "venueId"
            }
            
            #expect(hasVenueFk)
        }
    }
}

@Suite("DatabaseManager Tests")
struct DatabaseManagerTests {
    
    @Test("DatabaseManager initializes")
    func testDatabaseManagerInitialization() throws {
        let database = try createConferenceDatabase()
        let manager = DatabaseManager(database: database)

        // If we got here, initialization succeeded
        #expect(Bool(true))
    }
    
    @Test("DatabaseManager read operation")
    func testDatabaseManagerRead() async throws {
        let database = try createConferenceDatabase()
        let manager = DatabaseManager(database: database)
        
        let count = try await manager.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM conference") ?? 0
        }
        
        #expect(count == 0)
    }
    
    @Test("DatabaseManager write operation")
    func testDatabaseManagerWrite() async throws {
        let database = try createConferenceDatabase()
        let manager = DatabaseManager(database: database)
        
        try await manager.write { db in
            try db.execute(sql: """
                INSERT INTO conference (id, name, startDate, endDate, timezone, location)
                VALUES (?, ?, ?, ?, ?, ?)
                """, arguments: [
                UUID().uuidString,
                "Test Conf",
                Date(),
                Date(),
                "UTC",
                "Virtual"
            ])
        }
        
        let count = try await manager.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM conference") ?? 0
        }
        
        #expect(count == 1)
    }
    
    @Test("DatabaseManager statistics")
    func testDatabaseManagerStatistics() async throws {
        let database = try createConferenceDatabase()
        let manager = DatabaseManager(database: database)
        
        let stats = try await manager.statistics()
        
        #expect(stats.conferenceCount == 0)
        #expect(stats.sessionCount == 0)
        #expect(stats.speakerCount == 0)
        #expect(stats.venueCount == 0)
        #expect(stats.totalSizeBytes > 0)
    }
    
    @Test("DatabaseManager integrity check")
    func testDatabaseManagerIntegrityCheck() async throws {
        let database = try createConferenceDatabase()
        let manager = DatabaseManager(database: database)
        
        let isValid = try await manager.checkIntegrity()
        
        #expect(isValid == true)
    }
    
    @Test("DatabaseStatistics MB conversions")
    func testDatabaseStatisticsMBConversions() throws {
        let stats = DatabaseStatistics(
            totalSizeBytes: 2_097_152, // 2 MB
            usedSizeBytes: 1_048_576,  // 1 MB
            conferenceCount: 10,
            sessionCount: 50,
            speakerCount: 20,
            venueCount: 5
        )
        
        #expect(stats.totalSizeMB == 2.0)
        #expect(stats.usedSizeMB == 1.0)
        #expect(stats.freeSizeMB == 1.0)
    }
}
