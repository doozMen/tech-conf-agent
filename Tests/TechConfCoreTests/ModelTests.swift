import Testing
import Foundation
@testable import TechConfCore

@Suite("Conference Model Tests")
struct ConferenceModelTests {
    
    @Test("Conference initializes with all required fields")
    func testConferenceInitialization() {
        let startDate = Date()
        let endDate = Date(timeInterval: 86400 * 3, since: startDate)
        
        let conference = Conference(
            name: "SwiftConf 2025",
            tagline: "The Future of Swift",
            startDate: startDate,
            endDate: endDate,
            timezone: "America/New_York",
            location: "San Francisco, USA"
        )
        
        #expect(conference.name == "SwiftConf 2025")
        #expect(conference.tagline == "The Future of Swift")
        #expect(conference.timezone == "America/New_York")
        #expect(conference.location == "San Francisco, USA")
    }
    
    @Test("Conference computed property: isUpcoming")
    func testConferenceIsUpcoming() {
        let futureDate = Date(timeIntervalSinceNow: 86400 * 30)
        let conference = Conference(
            name: "Future Conf",
            startDate: futureDate,
            endDate: Date(timeInterval: 86400 * 3, since: futureDate),
            timezone: "UTC",
            location: "Virtual"
        )
        
        #expect(conference.isUpcoming == true)
        #expect(conference.isOngoing == false)
        #expect(conference.isPast == false)
    }
    
    @Test("Conference computed property: isOngoing")
    func testConferenceIsOngoing() {
        let yesterday = Date(timeIntervalSinceNow: -86400)
        let tomorrow = Date(timeIntervalSinceNow: 86400)
        
        let conference = Conference(
            name: "Current Conf",
            startDate: yesterday,
            endDate: tomorrow,
            timezone: "UTC",
            location: "Virtual"
        )
        
        #expect(conference.isOngoing == true)
        #expect(conference.isUpcoming == false)
        #expect(conference.isPast == false)
    }
    
    @Test("Conference computed property: isPast")
    func testConferenceIsPast() {
        let pastDate = Date(timeIntervalSinceNow: -86400 * 30)
        let conference = Conference(
            name: "Past Conf",
            startDate: pastDate,
            endDate: Date(timeInterval: 86400 * 3, since: pastDate),
            timezone: "UTC",
            location: "Virtual"
        )
        
        #expect(conference.isPast == true)
        #expect(conference.isUpcoming == false)
        #expect(conference.isOngoing == false)
    }
    
    @Test("Conference durationDays calculation")
    func testConferenceDurationDays() {
        let startDate = Date()
        let endDate = Date(timeInterval: 86400 * 2, since: startDate) // 3 days including start
        
        let conference = Conference(
            name: "3-Day Conf",
            startDate: startDate,
            endDate: endDate,
            timezone: "UTC",
            location: "Virtual"
        )
        
        #expect(conference.durationDays == 3)
    }
    
    @Test("Conference topicsArray decoding from JSON")
    func testConferenceTopicsArray() throws {
        let topics = ["iOS", "Swift", "SwiftUI", "Architecture"]
        let topicsJSON = try String(data: JSONEncoder().encode(topics), encoding: .utf8)
        
        let conference = Conference(
            name: "Tech Conf",
            startDate: Date(),
            endDate: Date(),
            timezone: "UTC",
            location: "Virtual",
            topics: topicsJSON
        )
        
        #expect(conference.topicsArray == topics)
    }
    
    @Test("Conference topicsArray returns empty for invalid JSON")
    func testConferenceTopicsArrayInvalid() {
        let conference = Conference(
            name: "Tech Conf",
            startDate: Date(),
            endDate: Date(),
            timezone: "UTC",
            location: "Virtual",
            topics: "invalid json"
        )
        
        #expect(conference.topicsArray.isEmpty)
    }
    
    @Test("Conference status: Starting today")
    func testConferenceStatusStartingToday() {
        let today = Calendar.current.startOfDay(for: Date())
        
        let conference = Conference(
            name: "Today Conf",
            startDate: today,
            endDate: Date(timeInterval: 86400 * 2, since: today),
            timezone: "UTC",
            location: "Virtual"
        )
        
        #expect(conference.status == "Starting today")
    }
    
    @Test("Conference formattedDateRange same month")
    func testConferenceFormattedDateRangeSameMonth() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = formatter.date(from: "2025-06-10")!
        let endDate = formatter.date(from: "2025-06-14")!
        
        let conference = Conference(
            name: "June Conf",
            startDate: startDate,
            endDate: endDate,
            timezone: "UTC",
            location: "Virtual"
        )
        
        #expect(conference.formattedDateRange.contains("Jun"))
        #expect(conference.formattedDateRange.contains("10"))
        #expect(conference.formattedDateRange.contains("14"))
        #expect(conference.formattedDateRange.contains("2025"))
    }
}

@Suite("Session Model Tests")
struct SessionModelTests {
    
    @Test("Session initializes with required fields")
    func testSessionInitialization() {
        let conferenceId = UUID()
        let startTime = Date()
        let endTime = Date(timeInterval: 3600, since: startTime)
        
        let session = Session(
            conferenceId: conferenceId,
            title: "Introduction to Swift Testing",
            startTime: startTime,
            endTime: endTime
        )
        
        #expect(session.title == "Introduction to Swift Testing")
        #expect(session.conferenceId == conferenceId)
        #expect(session.durationMinutes == 60)
    }
    
    @Test("Session format enum storage and retrieval")
    func testSessionFormatEnum() {
        let session = Session(
            conferenceId: UUID(),
            title: "Workshop Session",
            format: .workshop,
            startTime: Date(),
            endTime: Date()
        )
        
        #expect(session.format == .workshop)
    }
    
    @Test("Session difficulty level enum")
    func testSessionDifficultyLevel() {
        let session = Session(
            conferenceId: UUID(),
            title: "Advanced Swift",
            difficultyLevel: .advanced,
            startTime: Date(),
            endTime: Date()
        )
        
        #expect(session.difficultyLevel == .advanced)
        #expect(session.difficultyLabel == "Advanced")
    }
    
    @Test("Session formattedDuration: hours and minutes")
    func testSessionFormattedDurationHoursMinutes() {
        let startTime = Date()
        let endTime = Date(timeInterval: 5400, since: startTime) // 90 minutes
        
        let session = Session(
            conferenceId: UUID(),
            title: "Test Session",
            startTime: startTime,
            endTime: endTime
        )
        
        #expect(session.formattedDuration == "1h 30m")
    }
    
    @Test("Session formattedDuration: only hours")
    func testSessionFormattedDurationOnlyHours() {
        let startTime = Date()
        let endTime = Date(timeInterval: 7200, since: startTime) // 120 minutes
        
        let session = Session(
            conferenceId: UUID(),
            title: "Test Session",
            startTime: startTime,
            endTime: endTime
        )
        
        #expect(session.formattedDuration == "2h")
    }
    
    @Test("Session formattedDuration: only minutes")
    func testSessionFormattedDurationOnlyMinutes() {
        let startTime = Date()
        let endTime = Date(timeInterval: 2700, since: startTime) // 45 minutes
        
        let session = Session(
            conferenceId: UUID(),
            title: "Test Session",
            startTime: startTime,
            endTime: endTime
        )
        
        #expect(session.formattedDuration == "45m")
    }
    
    @Test("Session isOngoing status")
    func testSessionIsOngoing() {
        let startTime = Date(timeIntervalSinceNow: -1800) // 30 min ago
        let endTime = Date(timeIntervalSinceNow: 1800) // 30 min from now
        
        let session = Session(
            conferenceId: UUID(),
            title: "Current Session",
            startTime: startTime,
            endTime: endTime
        )
        
        #expect(session.isOngoing == true)
        #expect(session.isUpcoming == false)
        #expect(session.isPast == false)
        #expect(session.status == "In progress")
    }
    
    @Test("Session isUpcoming status")
    func testSessionIsUpcoming() {
        let startTime = Date(timeIntervalSinceNow: 3600) // 1 hour from now
        let endTime = Date(timeInterval: 3600, since: startTime)
        
        let session = Session(
            conferenceId: UUID(),
            title: "Future Session",
            startTime: startTime,
            endTime: endTime
        )
        
        #expect(session.isUpcoming == true)
        #expect(session.isOngoing == false)
        #expect(session.isPast == false)
    }
    
    @Test("Session isPast status")
    func testSessionIsPast() {
        let startTime = Date(timeIntervalSinceNow: -7200) // 2 hours ago
        let endTime = Date(timeIntervalSinceNow: -3600) // 1 hour ago
        
        let session = Session(
            conferenceId: UUID(),
            title: "Past Session",
            startTime: startTime,
            endTime: endTime
        )
        
        #expect(session.isPast == true)
        #expect(session.isOngoing == false)
        #expect(session.isUpcoming == false)
        #expect(session.status == "Ended")
    }
    
    @Test("Session tagsArray decoding")
    func testSessionTagsArray() throws {
        let tags = ["swift", "async", "performance"]
        let tagsJSON = try String(data: JSONEncoder().encode(tags), encoding: .utf8)
        
        let session = Session(
            conferenceId: UUID(),
            title: "Tagged Session",
            tags: tagsJSON,
            startTime: Date(),
            endTime: Date()
        )
        
        #expect(session.tagsArray == tags)
    }
    
    @Test("Session speakerIdsArray decoding")
    func testSessionSpeakerIdsArray() throws {
        let speakerIds = [UUID(), UUID()]
        let speakerIdsJSON = try String(data: JSONEncoder().encode(speakerIds), encoding: .utf8)
        
        let session = Session(
            conferenceId: UUID(),
            speakerIds: speakerIdsJSON,
            title: "Multi-Speaker Session",
            startTime: Date(),
            endTime: Date()
        )
        
        #expect(session.speakerIdsArray == speakerIds)
    }
    
    @Test("Session hasLimitedCapacity")
    func testSessionHasLimitedCapacity() {
        let session = Session(
            conferenceId: UUID(),
            title: "Workshop",
            startTime: Date(),
            endTime: Date(),
            capacity: 30
        )
        
        #expect(session.hasLimitedCapacity == true)
    }
    
    @Test("Session status: Starting soon")
    func testSessionStatusStartingSoon() {
        let startTime = Date(timeIntervalSinceNow: 1200) // 20 minutes
        let endTime = Date(timeInterval: 3600, since: startTime)
        
        let session = Session(
            conferenceId: UUID(),
            title: "Soon Session",
            startTime: startTime,
            endTime: endTime
        )
        
        #expect(session.status == "Starting soon")
    }
}

@Suite("Speaker Model Tests")
struct SpeakerModelTests {
    
    @Test("Speaker initializes with name")
    func testSpeakerInitialization() {
        let speaker = Speaker(name: "John Appleseed")
        
        #expect(speaker.name == "John Appleseed")
    }
    
    @Test("Speaker fullTitle with title and company")
    func testSpeakerFullTitle() {
        let speaker = Speaker(
            name: "Jane Doe",
            title: "iOS Engineer",
            company: "Apple"
        )
        
        #expect(speaker.fullTitle == "iOS Engineer at Apple")
    }
    
    @Test("Speaker fullTitle with only title")
    func testSpeakerFullTitleOnlyTitle() {
        let speaker = Speaker(
            name: "Jane Doe",
            title: "iOS Engineer"
        )
        
        #expect(speaker.fullTitle == "iOS Engineer")
    }
    
    @Test("Speaker fullTitle with only company")
    func testSpeakerFullTitleOnlyCompany() {
        let speaker = Speaker(
            name: "Jane Doe",
            company: "Apple"
        )
        
        #expect(speaker.fullTitle == "Apple")
    }
    
    @Test("Speaker fullTitle fallback to name")
    func testSpeakerFullTitleFallback() {
        let speaker = Speaker(name: "Jane Doe")
        
        #expect(speaker.fullTitle == "Jane Doe")
    }
    
    @Test("Speaker displayName with company")
    func testSpeakerDisplayName() {
        let speaker = Speaker(
            name: "John Doe",
            company: "Google"
        )
        
        #expect(speaker.displayName == "John Doe (Google)")
    }
    
    @Test("Speaker socialLinksDict decoding")
    func testSpeakerSocialLinksDict() throws {
        let socialLinks = ["twitter": "@johndoe", "github": "johndoe"]
        let socialLinksJSON = try String(data: JSONEncoder().encode(socialLinks), encoding: .utf8)
        
        let speaker = Speaker(
            name: "John Doe",
            socialLinks: socialLinksJSON
        )
        
        #expect(speaker.socialLinksDict == socialLinks)
        #expect(speaker.twitterHandle == "@johndoe")
        #expect(speaker.githubUsername == "johndoe")
        #expect(speaker.hasSocialLinks == true)
    }
    
    @Test("Speaker expertiseArray decoding")
    func testSpeakerExpertiseArray() throws {
        let expertise = ["iOS Development", "Swift", "Architecture"]
        let expertiseJSON = try String(data: JSONEncoder().encode(expertise), encoding: .utf8)
        
        let speaker = Speaker(
            name: "Expert Dev",
            expertise: expertiseJSON
        )
        
        #expect(speaker.expertiseArray == expertise)
    }
    
    @Test("Speaker experienceLevel: Junior")
    func testSpeakerExperienceLevelJunior() {
        let speaker = Speaker(
            name: "Junior Dev",
            yearsExperience: 2
        )
        
        #expect(speaker.experienceLevel == "Junior")
    }
    
    @Test("Speaker experienceLevel: Mid-level")
    func testSpeakerExperienceLevelMid() {
        let speaker = Speaker(
            name: "Mid Dev",
            yearsExperience: 5
        )
        
        #expect(speaker.experienceLevel == "Mid-level")
    }
    
    @Test("Speaker experienceLevel: Senior")
    func testSpeakerExperienceLevelSenior() {
        let speaker = Speaker(
            name: "Senior Dev",
            yearsExperience: 10
        )
        
        #expect(speaker.experienceLevel == "Senior")
    }
    
    @Test("Speaker experienceLevel: Expert")
    func testSpeakerExperienceLevelExpert() {
        let speaker = Speaker(
            name: "Expert Dev",
            yearsExperience: 15
        )
        
        #expect(speaker.experienceLevel == "Expert")
    }
    
    @Test("Speaker hasCompleteProfile")
    func testSpeakerHasCompleteProfile() throws {
        let expertise = ["iOS", "Swift"]
        let expertiseJSON = try String(data: JSONEncoder().encode(expertise), encoding: .utf8)
        
        let speaker = Speaker(
            name: "Complete Dev",
            title: "Engineer",
            company: "Apple",
            bio: "A great developer",
            expertise: expertiseJSON
        )
        
        #expect(speaker.hasCompleteProfile == true)
    }
    
    @Test("Speaker hasCompleteProfile: incomplete")
    func testSpeakerIncompleteProfile() {
        let speaker = Speaker(name: "Incomplete Dev")
        
        #expect(speaker.hasCompleteProfile == false)
    }
    
    @Test("Speaker speakingEngagements count")
    func testSpeakerSpeakingEngagements() throws {
        let conferences = ["WWConf 2024", "SwiftConf 2023", "iOSDevUK 2022"]
        let conferencesJSON = try String(data: JSONEncoder().encode(conferences), encoding: .utf8)
        
        let speaker = Speaker(
            name: "Experienced Speaker",
            previousConferences: conferencesJSON
        )
        
        #expect(speaker.speakingEngagements == 3)
    }
}

@Suite("Venue Model Tests")
struct VenueModelTests {
    
    @Test("Venue initializes with required fields")
    func testVenueInitialization() {
        let conferenceId = UUID()
        let venue = Venue(
            conferenceId: conferenceId,
            name: "Main Hall",
            capacity: 500
        )
        
        #expect(venue.name == "Main Hall")
        #expect(venue.capacity == 500)
        #expect(venue.conferenceId == conferenceId)
    }
    
    @Test("Venue fullName with building and room")
    func testVenueFullName() {
        let venue = Venue(
            conferenceId: UUID(),
            name: "Auditorium",
            building: "Convention Center",
            floor: "2",
            roomNumber: "201",
            capacity: 300
        )
        
        #expect(venue.fullName == "Convention Center - Auditorium - Floor 2 - Room 201")
    }
    
    @Test("Venue shortLocation")
    func testVenueShortLocation() {
        let venue = Venue(
            conferenceId: UUID(),
            name: "Hall A",
            building: "Building 1",
            roomNumber: "101",
            capacity: 200
        )
        
        #expect(venue.shortLocation == "Building 1 - Room 101")
    }
    
    @Test("Venue accessibilityDict decoding")
    func testVenueAccessibilityDict() throws {
        let accessibility = ["wheelchair": true, "hearingLoop": true, "signLanguage": false]
        let accessibilityJSON = try String(data: JSONEncoder().encode(accessibility), encoding: .utf8)
        
        let venue = Venue(
            conferenceId: UUID(),
            name: "Accessible Room",
            capacity: 100,
            accessibility: accessibilityJSON
        )
        
        #expect(venue.accessibilityDict.count == 3)
        #expect(venue.hasAccessibilityFeatures == true)
        #expect(venue.enabledAccessibilityFeatures.count == 2)
    }
    
    @Test("Venue equipmentArray decoding")
    func testVenueEquipmentArray() throws {
        let equipment = ["Projector", "Microphone", "Whiteboard"]
        let equipmentJSON = try String(data: JSONEncoder().encode(equipment), encoding: .utf8)
        
        let venue = Venue(
            conferenceId: UUID(),
            name: "Workshop Room",
            capacity: 50,
            equipment: equipmentJSON
        )
        
        #expect(venue.equipmentArray == equipment)
        #expect(venue.hasEquipment == true)
    }
    
    @Test("Venue coordinatesTuple decoding")
    func testVenueCoordinatesTuple() throws {
        let coordinates = ["latitude": 37.7749, "longitude": -122.4194]
        let coordinatesJSON = try String(data: JSONEncoder().encode(coordinates), encoding: .utf8)
        
        let venue = Venue(
            conferenceId: UUID(),
            name: "SF Venue",
            capacity: 300,
            coordinates: coordinatesJSON
        )
        
        let coords = venue.coordinatesTuple
        #expect(coords?.latitude == 37.7749)
        #expect(coords?.longitude == -122.4194)
        #expect(venue.hasLocationInfo == true)
    }
    
    @Test("Venue capacityCategory: Small")
    func testVenueCapacityCategorySmall() {
        let venue = Venue(
            conferenceId: UUID(),
            name: "Small Room",
            capacity: 30
        )
        
        #expect(venue.capacityCategory == "Small")
    }
    
    @Test("Venue capacityCategory: Medium")
    func testVenueCapacityCategoryMedium() {
        let venue = Venue(
            conferenceId: UUID(),
            name: "Medium Hall",
            capacity: 100
        )
        
        #expect(venue.capacityCategory == "Medium")
    }
    
    @Test("Venue capacityCategory: Large")
    func testVenueCapacityCategoryLarge() {
        let venue = Venue(
            conferenceId: UUID(),
            name: "Large Auditorium",
            capacity: 300
        )
        
        #expect(venue.capacityCategory == "Large")
    }
    
    @Test("Venue capacityCategory: Very Large")
    func testVenueCapacityCategoryVeryLarge() {
        let venue = Venue(
            conferenceId: UUID(),
            name: "Arena",
            capacity: 1000
        )
        
        #expect(venue.capacityCategory == "Very Large")
    }
    
    @Test("Venue effectiveCapacity with standing room")
    func testVenueEffectiveCapacityWithStanding() {
        let venue = Venue(
            conferenceId: UUID(),
            name: "Flexible Space",
            capacity: 100,
            hasStandingRoom: true
        )
        
        #expect(venue.effectiveCapacity == 120)
    }
    
    @Test("Venue effectiveCapacity without standing room")
    func testVenueEffectiveCapacityNoStanding() {
        let venue = Venue(
            conferenceId: UUID(),
            name: "Seated Only",
            capacity: 100,
            hasStandingRoom: false
        )
        
        #expect(venue.effectiveCapacity == 100)
    }
    
    @Test("Venue venueType: Physical")
    func testVenueTypePhysical() {
        let venue = Venue(
            conferenceId: UUID(),
            name: "Physical Room",
            capacity: 100,
            isVirtual: false
        )
        
        #expect(venue.venueType == "Physical")
    }
    
    @Test("Venue venueType: Virtual")
    func testVenueTypeVirtual() {
        let venue = Venue(
            conferenceId: UUID(),
            name: "Zoom Room",
            capacity: 500,
            isVirtual: true
        )
        
        #expect(venue.venueType == "Virtual")
    }
}

@Suite("Enum Tests")
struct EnumTests {
    
    @Test("SessionFormat all cases")
    func testSessionFormatCases() {
        let formats: [SessionFormat] = [
            .talk, .workshop, .panel, .keynote, .lightning, .roundtable, .networking
        ]
        
        for format in formats {
            #expect(!format.rawValue.isEmpty)
        }
    }
    
    @Test("DifficultyLevel all cases")
    func testDifficultyLevelCases() {
        let levels: [DifficultyLevel] = [
            .beginner, .intermediate, .advanced, .all
        ]
        
        for level in levels {
            #expect(!level.rawValue.isEmpty)
        }
    }
    
    @Test("SessionFormat codable")
    func testSessionFormatCodable() throws {
        let format = SessionFormat.workshop
        let encoded = try JSONEncoder().encode(format)
        let decoded = try JSONDecoder().decode(SessionFormat.self, from: encoded)
        
        #expect(decoded == format)
    }
    
    @Test("DifficultyLevel codable")
    func testDifficultyLevelCodable() throws {
        let level = DifficultyLevel.intermediate
        let encoded = try JSONEncoder().encode(level)
        let decoded = try JSONDecoder().decode(DifficultyLevel.self, from: encoded)
        
        #expect(decoded == level)
    }
}
