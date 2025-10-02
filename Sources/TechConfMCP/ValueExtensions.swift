import Foundation
import MCP
// import TechConfCore  // TODO: Re-enable when GRDB models are fixed

extension Value {
    /// Convert a Swift value to MCP Value
    static func from(_ value: Any) -> Value {
        switch value {
        case let string as String:
            return .string(string)
        case let int as Int:
            return .int(int)
        case let double as Double:
            return .double(double)
        case let bool as Bool:
            return .bool(bool)
        case let array as [Any]:
            return .array(array.map(Value.from))
        case let dict as [String: Any]:
            return .object(dict.mapValues(Value.from))
        default:
            return .string(String(describing: value))
        }
    }
    
    /// Convert MCP Value to JSON object
    func toJSONObject() -> Any {
        switch self {
        case .string(let string):
            return string
        case .int(let int):
            return int
        case .double(let double):
            return double
        case .bool(let bool):
            return bool
        case .array(let array):
            return array.map { $0.toJSONObject() }
        case .object(let dict):
            return dict.mapValues { $0.toJSONObject() }
        case .null:
            return NSNull()
        case .data(let mimeType, let data):
            return [
                "mimeType": mimeType,
                "data": data.base64EncodedString()
            ]
        }
    }
}

/*  // TODO: Re-enable when GRDB models are fixed
// MARK: - Conference Conversions

extension Value {
    /// Convert a Conference to MCP Value
    static func from(_ conference: Conference) -> Value {
        var dict: [String: Value] = [
            "id": .string(conference.id.uuidString),
            "name": .string(conference.name),
            "startDate": .string(ISO8601DateFormatter().string(from: conference.startDate)),
            "endDate": .string(ISO8601DateFormatter().string(from: conference.endDate)),
            "timezone": .string(conference.timezone),
            "location": .string(conference.location),
            "isVirtual": .bool(conference.isVirtual),
            "isAttending": .bool(conference.isAttending),
            "createdAt": .string(ISO8601DateFormatter().string(from: conference.createdAt)),
            "isUpcoming": .bool(conference.isUpcoming),
            "isOngoing": .bool(conference.isOngoing),
            "isPast": .bool(conference.isPast),
            "durationDays": .int(conference.durationDays),
            "status": .string(conference.status),
            "formattedDateRange": .string(conference.formattedDateRange)
        ]
        
        // Optional fields
        if let tagline = conference.tagline {
            dict["tagline"] = .string(tagline)
        }
        if let description = conference.description {
            dict["description"] = .string(description)
        }
        if let address = conference.address {
            dict["address"] = .string(address)
        }
        if let coordinates = conference.coordinates {
            dict["coordinates"] = .string(coordinates)
        }
        if let website = conference.website {
            dict["website"] = .string(website)
        }
        if let registrationURL = conference.registrationURL {
            dict["registrationURL"] = .string(registrationURL)
        }
        if let virtualPlatform = conference.virtualPlatform {
            dict["virtualPlatform"] = .string(virtualPlatform)
        }
        if let topics = conference.topics {
            dict["topics"] = .string(topics)
        }
        if let maxAttendees = conference.maxAttendees {
            dict["maxAttendees"] = .int(maxAttendees)
        }
        
        // Computed arrays
        if !conference.topicsArray.isEmpty {
            dict["topicsArray"] = .array(conference.topicsArray.map { .string($0) })
        }
        
        return .object(dict)
    }
    
    /// Convert an array of Conferences to MCP Value
    static func from(_ conferences: [Conference]) -> Value {
        .array(conferences.map { from($0) })
    }
}

// MARK: - Session Conversions

extension Value {
    /// Convert a Session to MCP Value
    static func from(_ session: Session) -> Value {
        var dict: [String: Value] = [
            "id": .string(session.id.uuidString),
            "conferenceId": .string(session.conferenceId.uuidString),
            "title": .string(session.title),
            "format": .string(session.format.rawValue),
            "difficultyLevel": .string(session.difficultyLevel.rawValue),
            "startTime": .string(ISO8601DateFormatter().string(from: session.startTime)),
            "endTime": .string(ISO8601DateFormatter().string(from: session.endTime)),
            "durationMinutes": .int(session.durationMinutes),
            "isRecorded": .bool(session.isRecorded),
            "isFavorited": .bool(session.isFavorited),
            "didAttend": .bool(session.didAttend),
            "createdAt": .string(ISO8601DateFormatter().string(from: session.createdAt)),
            "isUpcoming": .bool(session.isUpcoming),
            "isOngoing": .bool(session.isOngoing),
            "isPast": .bool(session.isPast),
            "status": .string(session.status),
            "formattedDuration": .string(session.formattedDuration),
            "formattedStartTime": .string(session.formattedStartTime),
            "formattedTimeRange": .string(session.formattedTimeRange),
            "difficultyLabel": .string(session.difficultyLabel)
        ]
        
        // Optional fields
        if let venueId = session.venueId {
            dict["venueId"] = .string(venueId.uuidString)
        }
        if let speakerIds = session.speakerIds {
            dict["speakerIds"] = .string(speakerIds)
        }
        if let description = session.description {
            dict["description"] = .string(description)
        }
        if let abstract = session.abstract {
            dict["abstract"] = .string(abstract)
        }
        if let track = session.track {
            dict["track"] = .string(track)
        }
        if let tags = session.tags {
            dict["tags"] = .string(tags)
        }
        if let capacity = session.capacity {
            dict["capacity"] = .int(capacity)
        }
        if let recordingURL = session.recordingURL {
            dict["recordingURL"] = .string(recordingURL)
        }
        if let slidesURL = session.slidesURL {
            dict["slidesURL"] = .string(slidesURL)
        }
        if let notes = session.notes {
            dict["notes"] = .string(notes)
        }
        if let rating = session.rating {
            dict["rating"] = .int(rating)
        }
        
        // Computed arrays
        if !session.tagsArray.isEmpty {
            dict["tagsArray"] = .array(session.tagsArray.map { .string($0) })
        }
        if !session.speakerIdsArray.isEmpty {
            dict["speakerIdsArray"] = .array(session.speakerIdsArray.map { .string($0.uuidString) })
        }
        
        return .object(dict)
    }
    
    /// Convert an array of Sessions to MCP Value
    static func from(_ sessions: [Session]) -> Value {
        .array(sessions.map { from($0) })
    }
}

// MARK: - Speaker Conversions

extension Value {
    /// Convert a Speaker to MCP Value
    static func from(_ speaker: Speaker) -> Value {
        var dict: [String: Value] = [
            "id": .string(speaker.id.uuidString),
            "name": .string(speaker.name),
            "isKeynoteSpeaker": .bool(speaker.isKeynoteSpeaker),
            "isFollowing": .bool(speaker.isFollowing),
            "createdAt": .string(ISO8601DateFormatter().string(from: speaker.createdAt)),
            "updatedAt": .string(ISO8601DateFormatter().string(from: speaker.updatedAt)),
            "fullTitle": .string(speaker.fullTitle),
            "displayName": .string(speaker.displayName),
            "experienceLevel": .string(speaker.experienceLevel),
            "hasCompleteProfile": .bool(speaker.hasCompleteProfile),
            "speakingEngagements": .int(speaker.speakingEngagements)
        ]
        
        // Optional fields
        if let title = speaker.title {
            dict["title"] = .string(title)
        }
        if let company = speaker.company {
            dict["company"] = .string(company)
        }
        if let bio = speaker.bio {
            dict["bio"] = .string(bio)
        }
        if let shortBio = speaker.shortBio {
            dict["shortBio"] = .string(shortBio)
        }
        if let email = speaker.email {
            dict["email"] = .string(email)
        }
        if let socialLinks = speaker.socialLinks {
            dict["socialLinks"] = .string(socialLinks)
        }
        if let websiteURL = speaker.websiteURL {
            dict["websiteURL"] = .string(websiteURL)
        }
        if let photoURL = speaker.photoURL {
            dict["photoURL"] = .string(photoURL)
        }
        if let expertise = speaker.expertise {
            dict["expertise"] = .string(expertise)
        }
        if let previousConferences = speaker.previousConferences {
            dict["previousConferences"] = .string(previousConferences)
        }
        if let yearsExperience = speaker.yearsExperience {
            dict["yearsExperience"] = .int(yearsExperience)
        }
        if let location = speaker.location {
            dict["location"] = .string(location)
        }
        if let timezone = speaker.timezone {
            dict["timezone"] = .string(timezone)
        }
        if let notes = speaker.notes {
            dict["notes"] = .string(notes)
        }
        
        // Computed fields
        if !speaker.expertiseArray.isEmpty {
            dict["expertiseArray"] = .array(speaker.expertiseArray.map { .string($0) })
        }
        if !speaker.previousConferencesArray.isEmpty {
            dict["previousConferencesArray"] = .array(speaker.previousConferencesArray.map { .string($0) })
        }
        if !speaker.socialLinksDict.isEmpty {
            dict["socialLinksDict"] = .object(speaker.socialLinksDict.mapValues { .string($0) })
        }
        if speaker.hasSocialLinks {
            dict["hasSocialLinks"] = .bool(true)
        }
        if let twitter = speaker.twitterHandle {
            dict["twitterHandle"] = .string(twitter)
        }
        if let linkedin = speaker.linkedInURL {
            dict["linkedInURL"] = .string(linkedin)
        }
        if let github = speaker.githubUsername {
            dict["githubUsername"] = .string(github)
        }
        if let mastodon = speaker.mastodonHandle {
            dict["mastodonHandle"] = .string(mastodon)
        }
        
        return .object(dict)
    }
    
    /// Convert an array of Speakers to MCP Value
    static func from(_ speakers: [Speaker]) -> Value {
        .array(speakers.map { from($0) })
    }
}

// MARK: - Venue Conversions

extension Value {
    /// Convert a Venue to MCP Value
    static func from(_ venue: Venue) -> Value {
        var dict: [String: Value] = [
            "id": .string(venue.id.uuidString),
            "conferenceId": .string(venue.conferenceId.uuidString),
            "name": .string(venue.name),
            "capacity": .int(venue.capacity),
            "hasStandingRoom": .bool(venue.hasStandingRoom),
            "isWheelchairAccessible": .bool(venue.isWheelchairAccessible),
            "hasLiveStream": .bool(venue.hasLiveStream),
            "isVirtual": .bool(venue.isVirtual),
            "isFavorited": .bool(venue.isFavorited),
            "createdAt": .string(ISO8601DateFormatter().string(from: venue.createdAt)),
            "fullName": .string(venue.fullName),
            "shortLocation": .string(venue.shortLocation),
            "capacityCategory": .string(venue.capacityCategory),
            "effectiveCapacity": .int(venue.effectiveCapacity),
            "venueType": .string(venue.venueType),
            "displayDescription": .string(venue.displayDescription),
            "hasAccessibilityFeatures": .bool(venue.hasAccessibilityFeatures),
            "hasEquipment": .bool(venue.hasEquipment),
            "hasLocationInfo": .bool(venue.hasLocationInfo)
        ]
        
        // Optional fields
        if let description = venue.description {
            dict["description"] = .string(description)
        }
        if let building = venue.building {
            dict["building"] = .string(building)
        }
        if let floor = venue.floor {
            dict["floor"] = .string(floor)
        }
        if let roomNumber = venue.roomNumber {
            dict["roomNumber"] = .string(roomNumber)
        }
        if let seatingArrangement = venue.seatingArrangement {
            dict["seatingArrangement"] = .string(seatingArrangement)
        }
        if let accessibility = venue.accessibility {
            dict["accessibility"] = .string(accessibility)
        }
        if let accessibilityNotes = venue.accessibilityNotes {
            dict["accessibilityNotes"] = .string(accessibilityNotes)
        }
        if let equipment = venue.equipment {
            dict["equipment"] = .string(equipment)
        }
        if let wifiNetwork = venue.wifiNetwork {
            dict["wifiNetwork"] = .string(wifiNetwork)
        }
        if let liveStreamURL = venue.liveStreamURL {
            dict["liveStreamURL"] = .string(liveStreamURL)
        }
        if let address = venue.address {
            dict["address"] = .string(address)
        }
        if let coordinates = venue.coordinates {
            dict["coordinates"] = .string(coordinates)
        }
        if let directions = venue.directions {
            dict["directions"] = .string(directions)
        }
        if let virtualPlatform = venue.virtualPlatform {
            dict["virtualPlatform"] = .string(virtualPlatform)
        }
        if let virtualMeetingURL = venue.virtualMeetingURL {
            dict["virtualMeetingURL"] = .string(virtualMeetingURL)
        }
        if let virtualMeetingId = venue.virtualMeetingId {
            dict["virtualMeetingId"] = .string(virtualMeetingId)
        }
        if let notes = venue.notes {
            dict["notes"] = .string(notes)
        }
        
        // Computed arrays and dicts
        if !venue.accessibilityDict.isEmpty {
            dict["accessibilityDict"] = .object(venue.accessibilityDict.mapValues { .bool($0) })
        }
        if !venue.equipmentArray.isEmpty {
            dict["equipmentArray"] = .array(venue.equipmentArray.map { .string($0) })
        }
        if !venue.enabledAccessibilityFeatures.isEmpty {
            dict["enabledAccessibilityFeatures"] = .array(venue.enabledAccessibilityFeatures.map { .string($0) })
        }
        if let coords = venue.coordinatesTuple {
            dict["coordinates"] = .object([
                "latitude": .double(coords.latitude),
                "longitude": .double(coords.longitude)
            ])
        }
        
        return .object(dict)
    }
    
    /// Convert an array of Venues to MCP Value
    static func from(_ venues: [Venue]) -> Value {
        .array(venues.map { from($0) })
    }
}
*/
