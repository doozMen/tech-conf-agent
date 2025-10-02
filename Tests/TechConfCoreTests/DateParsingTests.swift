import Testing
import Foundation
@testable import TechConfMCP

@Suite("Date Parsing Tests")
struct DateParsingTests {
    
    @Test("Parse ISO 8601 date with time")
    func testParseISO8601WithTime() {
        let dateString = "2025-10-02T14:30:00Z"
        let date = DateComponents.parse(dateString)
        
        #expect(date != nil)
    }
    
    @Test("Parse ISO 8601 date only")
    func testParseISO8601DateOnly() {
        let dateString = "2025-10-02"
        let date = DateComponents.parse(dateString)
        
        #expect(date != nil)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date!)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 2)
    }
    
    @Test("Parse natural language: today")
    func testParseToday() {
        let date = DateComponents.parse("today")
        
        #expect(date != nil)
        #expect(date?.isToday == true)
    }
    
    @Test("Parse natural language: tomorrow")
    func testParseTomorrow() {
        let date = DateComponents.parse("tomorrow")
        
        #expect(date != nil)
        #expect(date?.isTomorrow == true)
    }
    
    @Test("Parse natural language: yesterday")
    func testParseYesterday() {
        let date = DateComponents.parse("yesterday")
        
        #expect(date != nil)
        #expect(date?.isYesterday == true)
    }
    
    @Test("Parse weekday: monday")
    func testParseMonday() {
        let date = DateComponents.parse("monday")
        
        #expect(date != nil)
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date!)
        #expect(weekday == 2) // Monday is 2 in Calendar
    }
    
    @Test("Parse weekday: friday")
    func testParseFriday() {
        let date = DateComponents.parse("friday")
        
        #expect(date != nil)
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date!)
        #expect(weekday == 6) // Friday is 6 in Calendar
    }
    
    @Test("Parse next weekday: next monday")
    func testParseNextMonday() {
        let date = DateComponents.parse("next monday")
        
        #expect(date != nil)
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date!)
        #expect(weekday == 2) // Monday
        
        // Should be at least 7 days from now
        let daysFromNow = Calendar.current.dateComponents([.day], from: Date(), to: date!).day ?? 0
        #expect(daysFromNow >= 7)
    }
    
    @Test("Parse this week")
    func testParseThisWeek() {
        let date = DateComponents.parse("this week")
        
        #expect(date != nil)
        #expect(date?.isThisWeek == true)
    }
    
    @Test("Parse next week")
    func testParseNextWeek() {
        let date = DateComponents.parse("next week")
        
        #expect(date != nil)
        
        // Should be in the next week
        let calendar = Calendar.current
        let now = Date()
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: now)!
        
        #expect(calendar.isDate(date!, equalTo: nextWeek, toGranularity: .weekOfYear))
    }
    
    @Test("Parse this month")
    func testParseThisMonth() {
        let date = DateComponents.parse("this month")
        
        #expect(date != nil)
        #expect(date?.isThisMonth == true)
    }
    
    @Test("Parse next month")
    func testParseNextMonth() {
        let date = DateComponents.parse("next month")
        
        #expect(date != nil)
        
        let calendar = Calendar.current
        let now = Date()
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: now)!
        
        #expect(calendar.isDate(date!, equalTo: nextMonth, toGranularity: .month))
    }
    
    @Test("Parse invalid date string")
    func testParseInvalidDate() {
        let date = DateComponents.parse("not a date")
        
        #expect(date == nil)
    }
    
    @Test("Parse nil date string")
    func testParseNilDate() {
        let date = DateComponents.parse(nil)
        
        #expect(date == nil)
    }
    
    @Test("Parse empty date string")
    func testParseEmptyDate() {
        let date = DateComponents.parse("")
        
        #expect(date == nil)
    }
    
    @Test("Parse whitespace date string")
    func testParseWhitespaceDate() {
        let date = DateComponents.parse("   ")
        
        #expect(date == nil)
    }
    
    @Test("Parse case insensitive: TODAY")
    func testParseCaseInsensitive() {
        let date = DateComponents.parse("TODAY")
        
        #expect(date != nil)
        #expect(date?.isToday == true)
    }
}

@Suite("Date Extension Tests")
struct DateExtensionTests {
    
    @Test("Date startOfDay")
    func testStartOfDay() {
        let now = Date()
        let startOfDay = now.startOfDay
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startOfDay)
        
        #expect(components.hour == 0)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }
    
    @Test("Date endOfDay")
    func testEndOfDay() {
        let now = Date()
        let endOfDay = now.endOfDay
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: endOfDay)
        
        #expect(components.hour == 23)
        #expect(components.minute == 59)
        #expect(components.second == 59)
    }
    
    @Test("Date iso8601String")
    func testISO8601String() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let date = formatter.date(from: "2025-10-02 14:30:00")!
        let isoString = date.iso8601String
        
        #expect(isoString.contains("2025"))
        #expect(isoString.contains("10"))
        #expect(isoString.contains("02"))
    }
    
    @Test("Date isToday")
    func testIsToday() {
        let now = Date()
        
        #expect(now.isToday == true)
    }
    
    @Test("Date isTomorrow")
    func testIsTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        #expect(tomorrow.isTomorrow == true)
    }
    
    @Test("Date isYesterday")
    func testIsYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        #expect(yesterday.isYesterday == true)
    }
    
    @Test("Date isThisWeek")
    func testIsThisWeek() {
        let now = Date()
        
        #expect(now.isThisWeek == true)
    }
    
    @Test("Date isThisMonth")
    func testIsThisMonth() {
        let now = Date()
        
        #expect(now.isThisMonth == true)
    }
    
    @Test("Date relativeDescription: Today")
    func testRelativeDescriptionToday() {
        let today = Date()
        
        #expect(today.relativeDescription == "Today")
    }
    
    @Test("Date relativeDescription: Tomorrow")
    func testRelativeDescriptionTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        #expect(tomorrow.relativeDescription == "Tomorrow")
    }
    
    @Test("Date relativeDescription: Yesterday")
    func testRelativeDescriptionYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        #expect(yesterday.relativeDescription == "Yesterday")
    }
    
    @Test("Date daysBetween")
    func testDaysBetween() {
        let date1 = Date()
        let date2 = Calendar.current.date(byAdding: .day, value: 5, to: date1)!
        
        let days = date1.daysBetween(date2)
        
        #expect(days == 5)
    }
    
    @Test("Date hoursBetween")
    func testHoursBetween() {
        let date1 = Date()
        let date2 = Date(timeInterval: 7200, since: date1) // 2 hours
        
        let hours = date1.hoursBetween(date2)
        
        #expect(hours == 2)
    }
    
    @Test("Date minutesBetween")
    func testMinutesBetween() {
        let date1 = Date()
        let date2 = Date(timeInterval: 3600, since: date1) // 60 minutes
        
        let minutes = date1.minutesBetween(date2)
        
        #expect(minutes == 60)
    }
    
    @Test("Date formattedAs custom format")
    func testFormattedAsCustomFormat() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: "2025-10-02")!
        
        let formatted = date.formattedAs("MMM d, yyyy")
        
        #expect(formatted.contains("Oct"))
        #expect(formatted.contains("2"))
        #expect(formatted.contains("2025"))
    }
    
    @Test("Date shortDateString")
    func testShortDateString() {
        let date = Date()
        let shortDate = date.shortDateString
        
        #expect(!shortDate.isEmpty)
    }
    
    @Test("Date shortTimeString")
    func testShortTimeString() {
        let date = Date()
        let shortTime = date.shortTimeString
        
        #expect(!shortTime.isEmpty)
    }
}

@Suite("Calendar Extension Tests")
struct CalendarExtensionTests {
    
    @Test("Calendar startOfWeek")
    func testStartOfWeek() {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.startOfWeek(for: now)
        
        #expect(startOfWeek != nil)
    }
    
    @Test("Calendar endOfWeek")
    func testEndOfWeek() {
        let calendar = Calendar.current
        let now = Date()
        let endOfWeek = calendar.endOfWeek(for: now)
        
        #expect(endOfWeek != nil)
    }
    
    @Test("Calendar startOfMonth")
    func testStartOfMonth() {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.startOfMonth(for: now)
        
        #expect(startOfMonth != nil)
        
        let components = calendar.dateComponents([.day], from: startOfMonth!)
        #expect(components.day == 1)
    }
    
    @Test("Calendar endOfMonth")
    func testEndOfMonth() {
        let calendar = Calendar.current
        let now = Date()
        let endOfMonth = calendar.endOfMonth(for: now)
        
        #expect(endOfMonth != nil)
    }
    
    @Test("Week and month boundaries")
    func testWeekAndMonthBoundaries() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfWeek = calendar.startOfWeek(for: now),
              let endOfWeek = calendar.endOfWeek(for: now) else {
            return
        }
        
        #expect(startOfWeek < endOfWeek)
    }
}

@Suite("Date Parsing Edge Cases")
struct DateParsingEdgeCaseTests {
    
    @Test("Parse date with leading/trailing whitespace")
    func testParseWithWhitespace() {
        let date = DateComponents.parse("  today  ")
        
        #expect(date != nil)
        #expect(date?.isToday == true)
    }
    
    @Test("Parse date with mixed case")
    func testParseWithMixedCase() {
        let date = DateComponents.parse("ToMoRrOw")
        
        #expect(date != nil)
        #expect(date?.isTomorrow == true)
    }
    
    @Test("Parse all weekdays")
    func testParseAllWeekdays() {
        let weekdays = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        
        for weekday in weekdays {
            let date = DateComponents.parse(weekday)
            #expect(date != nil, "Failed to parse: \(weekday)")
        }
    }
    
    @Test("Parse all next weekdays")
    func testParseAllNextWeekdays() {
        let weekdays = ["next sunday", "next monday", "next tuesday", "next wednesday", 
                       "next thursday", "next friday", "next saturday"]
        
        for weekday in weekdays {
            let date = DateComponents.parse(weekday)
            #expect(date != nil, "Failed to parse: \(weekday)")
        }
    }
    
    @Test("Parse last week and last month")
    func testParseLastPeriods() {
        let lastWeek = DateComponents.parse("last week")
        let lastMonth = DateComponents.parse("last month")
        
        #expect(lastWeek != nil)
        #expect(lastMonth != nil)
        
        // Both should be in the past
        #expect(lastWeek! < Date())
        #expect(lastMonth! < Date())
    }
}
