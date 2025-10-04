import Foundation
import GRDB
import StructuredQueries

/// A conference speaker or presenter
///
/// Represents individuals who present sessions at conferences.
/// Speakers can present at multiple sessions and multiple conferences.
@Table("speaker")
public struct Speaker: Sendable, Codable, Identifiable, FetchableRecord, PersistableRecord {
  /// Unique identifier
  public let id: UUID

  // MARK: - Basic Information

  /// Speaker's full name
  public var name: String

  /// Job title or role
  public var title: String?

  /// Company or organization
  public var company: String?

  /// Professional biography
  public var bio: String?

  /// Short bio or tagline
  public var shortBio: String?

  // MARK: - Contact & Social

  /// Email address
  public var email: String?

  /// Social media links as JSON object (e.g., {"twitter": "@handle", "linkedin": "url", "github": "username"})
  public var socialLinks: String?

  /// Personal or professional website URL
  public var websiteURL: String?

  /// Profile photo URL
  public var photoURL: String?

  // MARK: - Professional Details

  /// Areas of expertise as JSON array (e.g., ["iOS Development", "Swift", "Architecture"])
  public var expertise: String?

  /// Previous conferences spoken at as JSON array
  public var previousConferences: String?

  /// Years of experience in the field
  public var yearsExperience: Int?

  /// Whether this is a keynote speaker
  public var isKeynoteSpeaker: Bool = false

  // MARK: - Location

  /// City and country (e.g., "San Francisco, USA")
  public var location: String?

  /// Timezone for scheduling purposes
  public var timezone: String?

  // MARK: - User Interaction

  /// Whether the user is following this speaker
  public var isFollowing: Bool = false

  /// User's personal notes about the speaker
  public var notes: String?

  // MARK: - Metadata

  /// When this speaker record was created
  public var createdAt: Date = Date()

  /// Last time the speaker's information was updated
  public var updatedAt: Date = Date()

  // MARK: - Initialization

  public init(
    id: UUID = UUID(),
    name: String,
    title: String? = nil,
    company: String? = nil,
    bio: String? = nil,
    shortBio: String? = nil,
    email: String? = nil,
    socialLinks: String? = nil,
    websiteURL: String? = nil,
    photoURL: String? = nil,
    expertise: String? = nil,
    previousConferences: String? = nil,
    yearsExperience: Int? = nil,
    isKeynoteSpeaker: Bool = false,
    location: String? = nil,
    timezone: String? = nil,
    isFollowing: Bool = false,
    notes: String? = nil,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.name = name
    self.title = title
    self.company = company
    self.bio = bio
    self.shortBio = shortBio
    self.email = email
    self.socialLinks = socialLinks
    self.websiteURL = websiteURL
    self.photoURL = photoURL
    self.expertise = expertise
    self.previousConferences = previousConferences
    self.yearsExperience = yearsExperience
    self.isKeynoteSpeaker = isKeynoteSpeaker
    self.location = location
    self.timezone = timezone
    self.isFollowing = isFollowing
    self.notes = notes
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

// MARK: - Computed Properties

extension Speaker {
  /// Full professional title (e.g., "iOS Engineer at Apple")
  public var fullTitle: String {
    switch (title, company) {
    case (let t?, let c?):
      return "\(t) at \(c)"
    case (let t?, nil):
      return t
    case (nil, let c?):
      return c
    case (nil, nil):
      return name
    }
  }

  /// Short display name with company (e.g., "John Doe (Apple)")
  public var displayName: String {
    if let company = company {
      return "\(name) (\(company))"
    }
    return name
  }

  /// Decoded social links as a dictionary
  public var socialLinksDict: [String: String] {
    guard let socialLinks = socialLinks,
      let data = socialLinks.data(using: .utf8),
      let dict = try? JSONDecoder().decode([String: String].self, from: data)
    else {
      return [:]
    }
    return dict
  }

  /// Decoded expertise array from JSON string
  public var expertiseArray: [String] {
    guard let expertise = expertise,
      let data = expertise.data(using: .utf8),
      let array = try? JSONDecoder().decode([String].self, from: data)
    else {
      return []
    }
    return array
  }

  /// Decoded previous conferences array from JSON string
  public var previousConferencesArray: [String] {
    guard let previousConferences = previousConferences,
      let data = previousConferences.data(using: .utf8),
      let array = try? JSONDecoder().decode([String].self, from: data)
    else {
      return []
    }
    return array
  }

  /// Twitter handle if available
  public var twitterHandle: String? {
    socialLinksDict["twitter"]
  }

  /// LinkedIn URL if available
  public var linkedInURL: String? {
    socialLinksDict["linkedin"]
  }

  /// GitHub username if available
  public var githubUsername: String? {
    socialLinksDict["github"]
  }

  /// Mastodon handle if available
  public var mastodonHandle: String? {
    socialLinksDict["mastodon"]
  }

  /// Whether the speaker has social media links
  public var hasSocialLinks: Bool {
    !socialLinksDict.isEmpty
  }

  /// Experience level based on years
  public var experienceLevel: String {
    guard let years = yearsExperience else {
      return "Unknown"
    }

    switch years {
    case 0..<3:
      return "Junior"
    case 3..<7:
      return "Mid-level"
    case 7..<12:
      return "Senior"
    default:
      return "Expert"
    }
  }

  /// Whether the speaker has a complete profile
  public var hasCompleteProfile: Bool {
    bio != nil && company != nil && title != nil && !expertiseArray.isEmpty
  }

  /// Number of previous speaking engagements
  public var speakingEngagements: Int {
    previousConferencesArray.count
  }
}
