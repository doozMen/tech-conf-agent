import Foundation

// MARK: - Natural Language Date Parsing

extension DateComponents {
    /// Parse a date string that can be in ISO 8601 format or natural language
    ///
    /// Supported formats:
    /// - ISO 8601: "2025-10-02", "2025-10-02T14:30:00Z"
    /// - Natural language: "today", "tomorrow", "yesterday"
    /// - Weekdays: "monday", "tuesday", etc. (refers to this week or next)
    /// - Relative: "next week", "this week"
    ///
    /// - Parameter input: The date string to parse
    /// - Returns: A Date if parsing succeeds, nil otherwise
    static func parse(_ input: String?) -> Date? {
        guard let input = input?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        
        // Try ISO 8601 format first (most common for APIs)
        if let isoDate = parseISO8601(input) {
            return isoDate
        }
        
        // Handle natural language dates
        let lowercased = input.lowercased()
        let calendar = Calendar.current
        let now = Date()
        
        switch lowercased {
        // Relative days
        case "today":
            return now.startOfDay
        case "yesterday":
            return calendar.date(byAdding: .day, value: -1, to: now)?.startOfDay
        case "tomorrow":
            return calendar.date(byAdding: .day, value: 1, to: now)?.startOfDay
            
        // Weekdays (this week or next)
        case "monday", "this monday":
            return getNextWeekday(2, from: now, calendar: calendar)
        case "tuesday", "this tuesday":
            return getNextWeekday(3, from: now, calendar: calendar)
        case "wednesday", "this wednesday":
            return getNextWeekday(4, from: now, calendar: calendar)
        case "thursday", "this thursday":
            return getNextWeekday(5, from: now, calendar: calendar)
        case "friday", "this friday":
            return getNextWeekday(6, from: now, calendar: calendar)
        case "saturday", "this saturday":
            return getNextWeekday(7, from: now, calendar: calendar)
        case "sunday", "this sunday":
            return getNextWeekday(1, from: now, calendar: calendar)
            
        // Next weekdays
        case "next monday":
            return getNextWeekday(2, from: now, calendar: calendar, skipCurrent: true)
        case "next tuesday":
            return getNextWeekday(3, from: now, calendar: calendar, skipCurrent: true)
        case "next wednesday":
            return getNextWeekday(4, from: now, calendar: calendar, skipCurrent: true)
        case "next thursday":
            return getNextWeekday(5, from: now, calendar: calendar, skipCurrent: true)
        case "next friday":
            return getNextWeekday(6, from: now, calendar: calendar, skipCurrent: true)
        case "next saturday":
            return getNextWeekday(7, from: now, calendar: calendar, skipCurrent: true)
        case "next sunday":
            return getNextWeekday(1, from: now, calendar: calendar, skipCurrent: true)
            
        // Week references
        case "this week":
            return calendar.dateInterval(of: .weekOfYear, for: now)?.start
        case "next week":
            return calendar.date(byAdding: .weekOfYear, value: 1, to: now)
                .flatMap { calendar.dateInterval(of: .weekOfYear, for: $0)?.start }
        case "last week":
            return calendar.date(byAdding: .weekOfYear, value: -1, to: now)
                .flatMap { calendar.dateInterval(of: .weekOfYear, for: $0)?.start }
            
        // Month references
        case "this month":
            return calendar.dateInterval(of: .month, for: now)?.start
        case "next month":
            return calendar.date(byAdding: .month, value: 1, to: now)
                .flatMap { calendar.dateInterval(of: .month, for: $0)?.start }
        case "last month":
            return calendar.date(byAdding: .month, value: -1, to: now)
                .flatMap { calendar.dateInterval(of: .month, for: $0)?.start }
            
        default:
            return nil
        }
    }
    
    /// Parse ISO 8601 date strings
    private static func parseISO8601(_ string: String) -> Date? {
        // Try full ISO 8601 with time first
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: string) {
            return date
        }
        
        // Try date-only format (YYYY-MM-DD)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: string)
    }
    
    /// Get the next occurrence of a weekday
    private static func getNextWeekday(
        _ weekday: Int,
        from date: Date,
        calendar: Calendar,
        skipCurrent: Bool = false
    ) -> Date? {
        let currentWeekday = calendar.component(.weekday, from: date)
        var daysToAdd = weekday - currentWeekday
        
        if skipCurrent || daysToAdd < 0 {
            daysToAdd += 7
        }
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: date)?.startOfDay
    }
}

// MARK: - Date Extensions

extension Date {
    /// The start of the day (00:00:00) for this date
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// The end of the day (23:59:59) for this date
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// Format the date using a specific format string
    ///
    /// Common formats:
    /// - "yyyy-MM-dd" → 2025-10-02
    /// - "MMM d, yyyy" → Oct 2, 2025
    /// - "EEEE, MMM d" → Thursday, Oct 2
    /// - "h:mm a" → 2:30 PM
    ///
    /// - Parameter format: The date format string
    /// - Returns: Formatted date string
    func formattedAs(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// Format the date using a predefined style
    ///
    /// - Parameters:
    ///   - dateStyle: The date style to use
    ///   - timeStyle: The time style to use
    /// - Returns: Formatted date string
    func formatted(
        dateStyle: DateFormatter.Style = .medium,
        timeStyle: DateFormatter.Style = .none
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
    
    /// Format the date as ISO 8601 string
    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }
    
    /// Format the date as a short date string (e.g., "Oct 2, 2025")
    var shortDateString: String {
        formatted(dateStyle: .medium)
    }
    
    /// Format the date as a short time string (e.g., "2:30 PM")
    var shortTimeString: String {
        formatted(dateStyle: .none, timeStyle: .short)
    }
    
    /// Check if this date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Check if this date is tomorrow
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    /// Check if this date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// Check if this date is in the current week
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Check if this date is in the current month
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    /// Get a relative description of this date (e.g., "Today", "Tomorrow", "Oct 2")
    var relativeDescription: String {
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else if isYesterday {
            return "Yesterday"
        } else if isThisWeek {
            return formattedAs("EEEE") // Day of week
        } else if isThisMonth {
            return formattedAs("MMM d") // Month and day
        } else {
            return formattedAs("MMM d, yyyy") // Full date
        }
    }
    
    /// Get the number of days between this date and another date
    func daysBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startOfDay, to: other.startOfDay)
        return abs(components.day ?? 0)
    }
    
    /// Get the number of hours between this date and another date
    func hoursBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: self, to: other)
        return abs(components.hour ?? 0)
    }
    
    /// Get the number of minutes between this date and another date
    func minutesBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: self, to: other)
        return abs(components.minute ?? 0)
    }
}

// MARK: - Calendar Extensions

extension Calendar {
    /// Get the start of the week for a given date
    func startOfWeek(for date: Date) -> Date? {
        dateInterval(of: .weekOfYear, for: date)?.start
    }
    
    /// Get the end of the week for a given date
    func endOfWeek(for date: Date) -> Date? {
        dateInterval(of: .weekOfYear, for: date)?.end
    }
    
    /// Get the start of the month for a given date
    func startOfMonth(for date: Date) -> Date? {
        dateInterval(of: .month, for: date)?.start
    }
    
    /// Get the end of the month for a given date
    func endOfMonth(for date: Date) -> Date? {
        dateInterval(of: .month, for: date)?.end
    }
}
