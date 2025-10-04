import Foundation
import StructuredQueries

/// QueryRepresentable conformance for SessionFormat enum
///
/// Enables SessionFormat to be used in structured queries by converting
/// to its rawValue (string) for database storage and querying.
extension SessionFormat: QueryRepresentable {
  /// Converts the session format to a query fragment (rawValue string)
  public var queryFragment: String {
    self.rawValue
  }
}

/// QueryRepresentable conformance for DifficultyLevel enum
///
/// Enables DifficultyLevel to be used in structured queries by converting
/// to its rawValue (string) for database storage and querying.
extension DifficultyLevel: QueryRepresentable {
  /// Converts the difficulty level to a query fragment (rawValue string)
  public var queryFragment: String {
    self.rawValue
  }
}
