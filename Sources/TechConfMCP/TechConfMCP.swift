import Foundation
import ArgumentParser
import Logging

@main
struct TechConfMCP: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "tech-conf-mcp",
        abstract: "Tech Conference Model Context Protocol server",
        version: "1.0.0"
    )

    @Option(name: .shortAndLong, help: "Log level (debug, info, warning, error)")
    var logLevel: String = "info"

    @Option(name: .long, help: "Database path")
    var dbPath: String?

    func run() async throws {
        // Configure logging to stderr (stdout is reserved for MCP protocol)
        let loggerLevel: Logger.Level
        switch logLevel.lowercased() {
        case "debug": loggerLevel = .debug
        case "info": loggerLevel = .info
        case "warning": loggerLevel = .warning
        case "error": loggerLevel = .error
        default: loggerLevel = .info
        }

        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardError(label: label)
            handler.logLevel = loggerLevel
            return handler
        }

        let logger = Logger(label: "tech-conf-mcp")
        logger.info("Starting Tech Conference MCP Server", metadata: [
            "version": "\(Self.configuration.version)",
            "logLevel": "\(loggerLevel)"
        ])

        // Create and run server
        do {
            let server = try TechConfMCPServer(logger: logger, databasePath: dbPath)
            try await server.run()
        } catch {
            logger.error("Failed to start server", metadata: [
                "error": "\(error)"
            ])
            throw error
        }
    }
}
