import Foundation
import GRDB

/// A conference venue or room
///
/// Represents physical or virtual locations where sessions take place.
/// Venues are associated with conferences and host multiple sessions.
public struct Venue: Sendable, Codable, Identifiable, FetchableRecord, PersistableRecord {
    public static let databaseTableName = "venue"
    /// Unique identifier
    public let id: UUID
    
    // MARK: - Relationships
    
    /// Reference to the parent conference
    public var conferenceId: UUID
    
    // MARK: - Basic Information
    
    /// Name of the venue or room (e.g., "Main Hall", "Room A", "Workshop Space 2")
    public var name: String
    
    /// Detailed description of the venue
    public var description: String?
    
    /// Building name if part of a larger complex
    public var building: String?
    
    /// Floor number or level
    public var floor: String?
    
    /// Room number or identifier
    public var roomNumber: String?
    
    // MARK: - Capacity
    
    /// Maximum number of people the venue can hold
    public var capacity: Int
    
    /// Seating arrangement type (e.g., "Theater", "Classroom", "Roundtable")
    public var seatingArrangement: String?
    
    /// Whether standing room is available
    public var hasStandingRoom: Bool = false
    
    // MARK: - Accessibility
    
    /// Accessibility features as JSON object (e.g., {"wheelchair": true, "hearingLoop": true, "signLanguage": false})
    public var accessibility: String?
    
    /// Whether the venue is wheelchair accessible
    public var isWheelchairAccessible: Bool = false
    
    /// Additional accessibility notes
    public var accessibilityNotes: String?
    
    // MARK: - Equipment & Amenities
    
    /// Available equipment as JSON array (e.g., ["Projector", "Microphone", "Whiteboard"])
    public var equipment: String?
    
    /// WiFi network name (if specific to this venue)
    public var wifiNetwork: String?
    
    /// Whether the venue has live streaming capability
    public var hasLiveStream: Bool = false
    
    /// Live stream URL if available
    public var liveStreamURL: String?
    
    // MARK: - Location Details
    
    /// Physical address of the venue
    public var address: String?
    
    /// Geographic coordinates as JSON (e.g., {"latitude": 37.7749, "longitude": -122.4194})
    public var coordinates: String?
    
    /// Directions or navigation instructions
    public var directions: String?
    
    // MARK: - Virtual Venue
    
    /// Whether this is a virtual venue
    public var isVirtual: Bool = false
    
    /// Virtual platform details (e.g., "Zoom Room 1", "Discord Stage")
    public var virtualPlatform: String?
    
    /// Virtual meeting link or room URL
    public var virtualMeetingURL: String?
    
    /// Virtual meeting ID or code
    public var virtualMeetingId: String?
    
    // MARK: - User Interaction
    
    /// User's personal notes about the venue
    public var notes: String?
    
    /// Whether the user has favorited this venue
    public var isFavorited: Bool = false
    
    // MARK: - Metadata
    
    /// When this venue record was created
    public var createdAt: Date = Date()
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        conferenceId: UUID,
        name: String,
        description: String? = nil,
        building: String? = nil,
        floor: String? = nil,
        roomNumber: String? = nil,
        capacity: Int,
        seatingArrangement: String? = nil,
        hasStandingRoom: Bool = false,
        accessibility: String? = nil,
        isWheelchairAccessible: Bool = false,
        accessibilityNotes: String? = nil,
        equipment: String? = nil,
        wifiNetwork: String? = nil,
        hasLiveStream: Bool = false,
        liveStreamURL: String? = nil,
        address: String? = nil,
        coordinates: String? = nil,
        directions: String? = nil,
        isVirtual: Bool = false,
        virtualPlatform: String? = nil,
        virtualMeetingURL: String? = nil,
        virtualMeetingId: String? = nil,
        notes: String? = nil,
        isFavorited: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.conferenceId = conferenceId
        self.name = name
        self.description = description
        self.building = building
        self.floor = floor
        self.roomNumber = roomNumber
        self.capacity = capacity
        self.seatingArrangement = seatingArrangement
        self.hasStandingRoom = hasStandingRoom
        self.accessibility = accessibility
        self.isWheelchairAccessible = isWheelchairAccessible
        self.accessibilityNotes = accessibilityNotes
        self.equipment = equipment
        self.wifiNetwork = wifiNetwork
        self.hasLiveStream = hasLiveStream
        self.liveStreamURL = liveStreamURL
        self.address = address
        self.coordinates = coordinates
        self.directions = directions
        self.isVirtual = isVirtual
        self.virtualPlatform = virtualPlatform
        self.virtualMeetingURL = virtualMeetingURL
        self.virtualMeetingId = virtualMeetingId
        self.notes = notes
        self.isFavorited = isFavorited
        self.createdAt = createdAt
    }
}

// MARK: - Computed Properties

extension Venue {
    /// Full venue name including building and room details
    public var fullName: String {
        var components: [String] = []
        
        if let building = building {
            components.append(building)
        }
        
        components.append(name)
        
        if let floor = floor {
            components.append("Floor \(floor)")
        }
        
        if let roomNumber = roomNumber {
            components.append("Room \(roomNumber)")
        }
        
        return components.joined(separator: " - ")
    }
    
    /// Short location identifier (e.g., "Building A - Room 101")
    public var shortLocation: String {
        var parts: [String] = []
        
        if let building = building {
            parts.append(building)
        }
        
        if let roomNumber = roomNumber {
            parts.append("Room \(roomNumber)")
        } else {
            parts.append(name)
        }
        
        return parts.joined(separator: " - ")
    }
    
    /// Decoded accessibility features as a dictionary
    public var accessibilityDict: [String: Bool] {
        guard let accessibility = accessibility,
              let data = accessibility.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: Bool].self, from: data) else {
            return [:]
        }
        return dict
    }
    
    /// Decoded equipment array from JSON string
    public var equipmentArray: [String] {
        guard let equipment = equipment,
              let data = equipment.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return array
    }
    
    /// Geographic coordinates as a tuple (latitude, longitude)
    public var coordinatesTuple: (latitude: Double, longitude: Double)? {
        guard let coordinates = coordinates,
              let data = coordinates.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: Double].self, from: data),
              let lat = dict["latitude"],
              let lon = dict["longitude"] else {
            return nil
        }
        return (lat, lon)
    }
    
    /// Whether the venue has accessibility features
    public var hasAccessibilityFeatures: Bool {
        isWheelchairAccessible || !accessibilityDict.isEmpty
    }
    
    /// List of enabled accessibility features
    public var enabledAccessibilityFeatures: [String] {
        accessibilityDict.filter { $0.value }.map { $0.key }
    }
    
    /// Whether the venue has equipment
    public var hasEquipment: Bool {
        !equipmentArray.isEmpty
    }
    
    /// Capacity category
    public var capacityCategory: String {
        switch capacity {
        case 0..<50:
            return "Small"
        case 50..<150:
            return "Medium"
        case 150..<500:
            return "Large"
        default:
            return "Very Large"
        }
    }
    
    /// Effective capacity including standing room
    public var effectiveCapacity: Int {
        hasStandingRoom ? Int(Double(capacity) * 1.2) : capacity
    }
    
    /// Venue type (physical or virtual)
    public var venueType: String {
        isVirtual ? "Virtual" : "Physical"
    }
    
    /// Display description including key features
    public var displayDescription: String {
        var parts: [String] = []
        
        parts.append("\(capacityCategory) venue")
        parts.append("Capacity: \(capacity)")
        
        if isWheelchairAccessible {
            parts.append("Wheelchair accessible")
        }
        
        if hasLiveStream {
            parts.append("Live streaming available")
        }
        
        if isVirtual {
            parts.append("Virtual venue")
        }
        
        return parts.joined(separator: " • ")
    }
    
    /// Whether venue has location information
    public var hasLocationInfo: Bool {
        address != nil || coordinatesTuple != nil
    }
}
