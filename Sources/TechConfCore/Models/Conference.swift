import Foundation
import GRDB

/// A technology conference event
///
/// Represents a multi-day conference with location, timing, and metadata.
/// Conferences serve as the top-level container for sessions, speakers, and venues.
public struct Conference: Sendable, Codable, Identifiable, FetchableRecord, PersistableRecord {
    public static let databaseTableName = "conference"
    /// Unique identifier
    public let id: UUID
    
    // MARK: - Basic Information
    
    /// The official name of the conference
    public var name: String
    
    /// Conference tagline or subtitle
    public var tagline: String?
    
    /// Detailed description of the conference
    public var description: String?
    
    // MARK: - Timing
    
    /// When the conference starts (first day, typically 00:00 local time)
    public var startDate: Date
    
    /// When the conference ends (last day, typically 23:59 local time)
    public var endDate: Date
    
    /// IANA timezone identifier (e.g., "America/New_York", "Europe/Paris")
    public var timezone: String
    
    // MARK: - Location
    
    /// City and country of the conference (e.g., "San Francisco, USA")
    public var location: String
    
    /// Full address of the conference venue
    public var address: String?
    
    /// Geographic coordinates stored as JSON (e.g., {"latitude": 37.7749, "longitude": -122.4194})
    public var coordinates: String?
    
    // MARK: - Online Information
    
    /// Official conference website URL
    public var website: String?
    
    /// URL for event registration/tickets
    public var registrationURL: String?
    
    /// Whether this is a virtual/online conference
    public var isVirtual: Bool = false
    
    /// Virtual platform details (e.g., "Zoom", "Hopin")
    public var virtualPlatform: String?
    
    // MARK: - Metadata
    
    /// Conference topics/tracks as JSON array (e.g., ["iOS", "Swift", "SwiftUI"])
    public var topics: String?
    
    /// Maximum number of attendees
    public var maxAttendees: Int?
    
    /// When this conference record was created
    public var createdAt: Date = Date()
    
    /// Whether the user is registered/attending
    public var isAttending: Bool = false
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        name: String,
        tagline: String? = nil,
        description: String? = nil,
        startDate: Date,
        endDate: Date,
        timezone: String,
        location: String,
        address: String? = nil,
        coordinates: String? = nil,
        website: String? = nil,
        registrationURL: String? = nil,
        isVirtual: Bool = false,
        virtualPlatform: String? = nil,
        topics: String? = nil,
        maxAttendees: Int? = nil,
        createdAt: Date = Date(),
        isAttending: Bool = false
    ) {
        self.id = id
        self.name = name
        self.tagline = tagline
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.timezone = timezone
        self.location = location
        self.address = address
        self.coordinates = coordinates
        self.website = website
        self.registrationURL = registrationURL
        self.isVirtual = isVirtual
        self.virtualPlatform = virtualPlatform
        self.topics = topics
        self.maxAttendees = maxAttendees
        self.createdAt = createdAt
        self.isAttending = isAttending
    }
}

// MARK: - Computed Properties

extension Conference {
    /// Whether the conference is in the future
    public var isUpcoming: Bool {
        startDate > Date()
    }
    
    /// Whether the conference is currently happening
    public var isOngoing: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    /// Whether the conference has already ended
    public var isPast: Bool {
        endDate < Date()
    }
    
    /// Number of days the conference runs
    public var durationDays: Int {
        let components = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1 // Include both start and end days
    }
    
    /// Days until the conference starts (negative if already started/past)
    public var daysUntilStart: Int {
        let components = Calendar.current.dateComponents([.day], from: Date(), to: startDate)
        return components.day ?? 0
    }
    
    /// Formatted date range string (e.g., "Jun 10-14, 2025")
    public var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startStr = formatter.string(from: startDate)
        
        // If same month and year, just show end day
        let calendar = Calendar.current
        if calendar.component(.month, from: startDate) == calendar.component(.month, from: endDate),
           calendar.component(.year, from: startDate) == calendar.component(.year, from: endDate) {
            let endDay = calendar.component(.day, from: endDate)
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            return "\(startStr)-\(endDay), \(yearFormatter.string(from: startDate))"
        }
        
        formatter.dateFormat = "MMM d, yyyy"
        return "\(startStr) - \(formatter.string(from: endDate))"
    }
    
    /// Conference status as a human-readable string
    public var status: String {
        if isOngoing {
            return "Happening now"
        } else if isUpcoming {
            if daysUntilStart == 0 {
                return "Starting today"
            } else if daysUntilStart == 1 {
                return "Starting tomorrow"
            } else if daysUntilStart <= 7 {
                return "Starting in \(daysUntilStart) days"
            } else {
                return "Upcoming"
            }
        } else {
            return "Past"
        }
    }
    
    /// Decoded topics array from JSON string
    public var topicsArray: [String] {
        guard let topics = topics,
              let data = topics.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return array
    }
}
