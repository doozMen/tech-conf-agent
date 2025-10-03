# Changelog

All notable changes to Tech Conference MCP will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-03

### Added
- 6 MCP tools for conference navigation:
  - `list_sessions` - Filter sessions by track, format, difficulty, speaker, or conference
  - `search_sessions` - Full-text search across session titles and descriptions
  - `get_speaker` - Retrieve comprehensive speaker profiles with bios and social links
  - `get_schedule` - Get sessions for specific dates with natural language support ("today", "tomorrow")
  - `find_room` - Find venue and room information
  - `get_session_details` - Get detailed information about specific sessions
- Comprehensive speaker data for ServerSide.swift 2025 London (27+ speakers)
- Full speaker profiles with bios, expertise areas, and social links (GitHub, Twitter, LinkedIn)
- Actor-based Swift 6.2 MCP server with strict concurrency
- SQLite database backend with GRDB migrations
- Natural language date parsing ("today", "tomorrow", "next monday")
- 191 unit tests with Swift Testing framework (97.4% pass rate)
- Sample conference data (ServerSide.swift 2025)
- 2 specialized agents:
  - `conference-specialist` - Expert conference navigation with speaker discovery
  - `swift-server` - Server-side Swift development with framework expert mappings

### Documentation
- README.md - Project overview and quick start
- USAGE.md - Comprehensive tool reference with real examples
- CLAUDE.md - Developer guide with Swift 6.2 patterns and architecture
- TEST-CASES.md - 30+ test cases with expected outputs
- INSTALLATION.md - Detailed installation and configuration guide
- CONTRIBUTING.md - Contributing guidelines with Swift 6.2 requirements
- SECURITY.md - Security policy and vulnerability reporting
- CODE_OF_CONDUCT.md - Contributor Covenant Code of Conduct

### Infrastructure
- MIT License for open source distribution
- Conventional commits for clean git history
- Swift format configuration for consistent code style
- GitHub repository ready for public collaboration

## Unreleased Features

### Planned
- TechConfSync module for external conference data integration
- Additional conference datasets (try! Swift, SwiftConf, etc.)
- Advanced search filters (multi-track, time ranges)
- Session recommendations based on expertise
- Speaker networking suggestions

---

**Repository**: https://github.com/doozMen/tech-conf-agent
**License**: MIT
**Swift Version**: 6.2
**Platform**: macOS 15.0+
