import Foundation
import GRDB
import StructuredQueries

/// The format/type of a conference session
public enum SessionFormat: String, Sendable, Codable, DatabaseValueConvertible, QueryBindable {
  case talk
  case workshop
  case panel
  case keynote
  case lightning
  case roundtable
  case networking
}

/// The difficulty level of a session
public enum DifficultyLevel: String, Sendable, Codable, DatabaseValueConvertible, QueryBindable {
  case beginner
  case intermediate
  case advanced
  case all
}

/// A conference session or presentation
///
/// Represents individual talks, workshops, panels, or other session types
/// within a conference. Sessions are linked to conferences, speakers, and venues.
@Table("session")
public struct Session: Sendable, Codable, Identifiable, FetchableRecord, PersistableRecord {
  /// Unique identifier
  public let id: UUID

  // MARK: - Relationships

  /// Reference to the parent conference
  public var conferenceId: UUID

  /// Reference to the venue where this session takes place
  public var venueId: UUID?

  /// Speaker IDs as JSON array (e.g., ["uuid1", "uuid2"])
  public var speakerIds: String?

  // MARK: - Basic Information

  /// Session title
  public var title: String

  /// Detailed description of the session content
  public var description: String?

  /// Abstract or summary (shorter than description)
  public var abstract: String?

  // MARK: - Session Details

  /// Format of the session
  @Column("format")
  public var format: SessionFormat = .talk

  /// Difficulty level
  @Column("difficultyLevel")
  public var difficultyLevel: DifficultyLevel = .all

  /// Track name (e.g., "iOS Development", "Backend", "Design")
  public var track: String?

  /// Session tags as JSON array (e.g., ["swift", "async", "performance"])
  public var tags: String?

  // MARK: - Timing

  /// When the session starts
  public var startTime: Date

  /// When the session ends
  public var endTime: Date

  /// Duration in minutes (calculated from start/end times)
  public var durationMinutes: Int

  // MARK: - Capacity & Recording

  /// Maximum number of attendees (for workshops/limited sessions)
  public var capacity: Int?

  /// Whether the session will be recorded
  public var isRecorded: Bool = false

  /// URL to session recording (available after the session)
  public var recordingURL: String?

  /// URL to session slides/materials
  public var slidesURL: String?

  // MARK: - User Interaction

  /// Whether the user has marked this session for attendance
  public var isFavorited: Bool = false

  /// Whether the user attended this session
  public var didAttend: Bool = false

  /// User's personal notes about the session
  public var notes: String?

  /// User's rating (1-5 stars)
  public var rating: Int?

  // MARK: - Metadata

  /// When this session record was created
  public var createdAt: Date = Date()

  // MARK: - Initialization

  public init(
    id: UUID = UUID(),
    conferenceId: UUID,
    venueId: UUID? = nil,
    speakerIds: String? = nil,
    title: String,
    description: String? = nil,
    abstract: String? = nil,
    format: SessionFormat = .talk,
    difficultyLevel: DifficultyLevel = .all,
    track: String? = nil,
    tags: String? = nil,
    startTime: Date,
    endTime: Date,
    durationMinutes: Int? = nil,
    capacity: Int? = nil,
    isRecorded: Bool = false,
    recordingURL: String? = nil,
    slidesURL: String? = nil,
    isFavorited: Bool = false,
    didAttend: Bool = false,
    notes: String? = nil,
    rating: Int? = nil,
    createdAt: Date = Date()
  ) {
    self.id = id
    self.conferenceId = conferenceId
    self.venueId = venueId
    self.speakerIds = speakerIds
    self.title = title
    self.description = description
    self.abstract = abstract
    self.format = format
    self.difficultyLevel = difficultyLevel
    self.track = track
    self.tags = tags
    self.startTime = startTime
    self.endTime = endTime
    self.durationMinutes = durationMinutes ?? Int(endTime.timeIntervalSince(startTime) / 60)
    self.capacity = capacity
    self.isRecorded = isRecorded
    self.recordingURL = recordingURL
    self.slidesURL = slidesURL
    self.isFavorited = isFavorited
    self.didAttend = didAttend
    self.notes = notes
    self.rating = rating
    self.createdAt = createdAt
  }
}

// MARK: - Computed Properties

extension Session {
  /// Duration as a TimeInterval
  public var duration: TimeInterval {
    TimeInterval(durationMinutes * 60)
  }

  /// Formatted duration string (e.g., "1h 30m", "45m")
  public var formattedDuration: String {
    let hours = durationMinutes / 60
    let minutes = durationMinutes % 60

    if hours > 0 && minutes > 0 {
      return "\(hours)h \(minutes)m"
    } else if hours > 0 {
      return "\(hours)h"
    } else {
      return "\(minutes)m"
    }
  }

  /// Whether the session is currently happening
  public var isOngoing: Bool {
    let now = Date()
    return now >= startTime && now <= endTime
  }

  /// Whether the session is in the future
  public var isUpcoming: Bool {
    startTime > Date()
  }

  /// Whether the session has already ended
  public var isPast: Bool {
    endTime < Date()
  }

  /// Minutes until the session starts (negative if already started/past)
  public var minutesUntilStart: Int {
    let components = Calendar.current.dateComponents([.minute], from: Date(), to: startTime)
    return components.minute ?? 0
  }

  /// Formatted start time (e.g., "2:30 PM")
  public var formattedStartTime: String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: startTime)
  }

  /// Formatted time range (e.g., "2:30 PM - 3:45 PM")
  public var formattedTimeRange: String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
  }

  /// Decoded tags array from JSON string
  public var tagsArray: [String] {
    guard let tags = tags,
      let data = tags.data(using: .utf8),
      let array = try? JSONDecoder().decode([String].self, from: data)
    else {
      return []
    }
    return array
  }

  /// Decoded speaker IDs array from JSON string
  public var speakerIdsArray: [UUID] {
    guard let speakerIds = speakerIds,
      let data = speakerIds.data(using: .utf8),
      let array = try? JSONDecoder().decode([UUID].self, from: data)
    else {
      return []
    }
    return array
  }

  /// Whether this session has limited capacity
  public var hasLimitedCapacity: Bool {
    capacity != nil
  }

  /// Session status as a human-readable string
  public var status: String {
    if isOngoing {
      return "In progress"
    } else if isUpcoming {
      if minutesUntilStart <= 30 {
        return "Starting soon"
      } else {
        return "Upcoming"
      }
    } else {
      return "Ended"
    }
  }

  /// Display label for difficulty level
  public var difficultyLabel: String {
    switch difficultyLevel {
    case .beginner: return "Beginner"
    case .intermediate: return "Intermediate"
    case .advanced: return "Advanced"
    case .all: return "All levels"
    }
  }
}
