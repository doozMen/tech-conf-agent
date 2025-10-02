# Changelog

All notable changes to Tech Conference MCP Server will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - Unreleased

### Initial Release: Conference Management MCP Server

#### Added
- **Core MCP Server Implementation**:
  - `list_sessions` tool for browsing all conference sessions with optional filtering
  - `search_sessions` tool for natural language session queries
  - `get_speaker` tool for retrieving speaker profiles and their sessions
  - `get_schedule` tool for querying schedules by day or time range
  - `find_room` tool for locating venues and checking room schedules
  - `get_session_details` tool for comprehensive session information
  
- **Domain Models**:
  - `Session` model with title, description, time, track, and tags
  - `Speaker` model with bio, expertise, contact information, and social links
  - `Room` model with venue details, capacity, and equipment information
  - Many-to-many relationships between sessions and speakers
  - Tagging system for categorical filtering
  
- **Database Layer**:
  - SQLite database with SharingGRDB for type-safe queries
  - Migration system for schema evolution
  - Indexed queries for performance optimization
  - Observable database changes for real-time updates
  
- **Natural Language Processing**:
  - Date parsing supporting relative ("today", "tomorrow") and absolute formats
  - Time range parsing ("2pm-4pm", "afternoon", "morning")
  - Fuzzy search across session titles, descriptions, and speaker names
  - Tag-based filtering and categorization
  
- **Sample Conference Data**:
  - **ServerSide.swift 2025** conference dataset
  - 50+ sessions across Swift server, iOS, and tooling topics
  - 30+ speaker profiles with bios and social links
  - 3-day schedule (October 15-17, 2025)
  - 6 venue rooms with detailed specifications
  
#### Technical Architecture
- **Swift 6.2**: Modern Swift with strict concurrency checking
- **Actor-based Concurrency**: Thread-safe data access using Swift actors
- **MCP SDK Integration**: Official Model Context Protocol implementation
- **Type-Safe Queries**: SharingGRDB for compile-time SQL safety
- **Modular Design**: 3-module architecture (Core, MCP, Executable)

#### Developer Experience
- **Swift Testing Framework**: Comprehensive test suite with modern Swift Testing
- **Database Migrations**: Version-controlled schema evolution
- **CLI Installation**: `swift package experimental-install` for easy deployment
- **Claude Desktop Integration**: Ready-to-use MCP server configuration
- **Documentation**: Complete README with usage examples and architecture guide

#### Installation & Configuration
- macOS 15+ platform support
- Swift Package Manager integration
- Claude Desktop configuration template
- Environment setup with PATH configuration for SwiftPM bin directory

### Sample Queries Supported
- "Show me all Swift talks tomorrow"
- "Who is speaking about concurrency?"
- "What's in the main hall at 2pm?"
- "Find sessions about server-side Swift"
- "Tell me about [speaker name]'s background"
- "What sessions are in Track A this afternoon?"

### Dependencies
- **MCP Swift SDK** - Model Context Protocol implementation
- **SharingGRDB** - Type-safe SQLite database layer
- **Swift 6.2+** - Modern Swift concurrency and language features

### Credits
Reference implementations and inspiration from:
- TimeStory MCP - MCP server patterns in Swift
- MCP Swift SDK - Official protocol implementation
- SharingGRDB - Observable database queries

---

## Future Releases

### [1.1.0] - Planned
- **Export Tools**: Export schedules to calendar formats (ICS, Google Calendar)
- **Conflict Detection**: Identify scheduling conflicts for attendees
- **Personalization**: User favorites and custom schedules
- **Multi-Conference**: Support for multiple conferences in one database

### [1.2.0] - Planned  
- **Live Updates**: Real-time schedule changes and announcements
- **Notifications**: Session reminders and track updates
- **Analytics**: Popular sessions and attendance predictions
- **Social Integration**: Twitter/Mastodon conference feed integration

### [2.0.0] - Future
- **API Server Mode**: REST API alongside MCP protocol
- **Web Interface**: Browser-based conference schedule viewer
- **Mobile Sync**: iOS companion app integration
- **Multi-Platform**: Linux support for server deployments
