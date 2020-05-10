import Foundation
import CLibical

typealias Second = Int
typealias Minute = Int
typealias Hour = Int
typealias Day = Int
typealias MonthDay = Int
typealias YearDay = Int
typealias WeekNumber = Int
typealias Month = Int
typealias Setpos = Int

/// RecurranceRule
public struct RecurranceRule {

    /// Options for the repeat fequency of a `RecurranceRule`.
    ///
    /// See [RFC 5545 Section 3.3.10](https://tools.ietf.org/html/rfc5545#section-3.3.10) for more details.
    public enum Frequency {

        /// Repeat every second
        case secondly

        /// Repeat every minute
        case minutely

        /// Repeat every hour
        case hourly

        /// Repeat every day
        case daily

        /// Repeat every week
        case weekly

        /// Repeat every month
        case monthly

        /// Repeat every year
        case yearly
    }

    public enum Weekday {
        case sunday
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }

    enum Month: Int {
        case janurary = 1
        case february = 2
        case march = 3
        case april = 4
        case may = 5
        case june = 6
        case july = 7
        case august = 8
        case september = 9
        case october = 10
        case november = 11
        case december = 12
    }

    /// Creates a new `RecurranceRule`
    ///
    /// - parameter frequency: Repeat frequency for the repeat rule. See `RecurranceRule.Frequency` for options.
    public init(frequency: Frequency) {
        self.frequency = frequency
    }

    let frequency: Frequency
    let until: DateComponents? = nil
    let count: Int? = nil

    /// Interval at which intervals the recurrence rule repeats
    ///
    /// The default value is
    /// "1", meaning every second for a SECONDLY rule, every minute for a
    /// MINUTELY rule, every hour for an HOURLY rule, every day for a
    /// DAILY rule, every week for a WEEKLY rule, every month for a
    /// MONTHLY rule, and every year for a YEARLY rule.  For example,
    /// within a DAILY rule, a value of "8" means every eight days.
    var interval: Int = 1

    var bySecond = Set<Second>()
    var byMinute = Set<Minute>()
    var byHour = Set<Hour>()
    var byDay = Set<Day>()
    var byMonthDay = Set<MonthDay>()
    var byYearDay = Set<YearDay>()
    var byWeekNumber = Set<WeekNumber>()
    var byMonth = Set<Month>()
    var bySetpos = Set<Setpos>()

}

extension RecurranceRule.Frequency {
    var icalFrequency: icalrecurrencetype_frequency {
        switch self {
        case .secondly:
            return ICAL_SECONDLY_RECURRENCE
        case .minutely:
            return ICAL_MINUTELY_RECURRENCE
        case .hourly:
            return ICAL_HOURLY_RECURRENCE
        case .daily:
            return ICAL_DAILY_RECURRENCE
        case .weekly:
            return ICAL_WEEKLY_RECURRENCE
        case .monthly:
            return ICAL_MONTHLY_RECURRENCE
        case .yearly:
            return ICAL_YEARLY_RECURRENCE
        }
    }
}



extension RecurranceRule.Weekday {
    var icalRecurrenceWeekday:icalrecurrencetype_weekday {
        switch self {
        case .sunday:
            return ICAL_SUNDAY_WEEKDAY
        case .monday:
            return ICAL_MONDAY_WEEKDAY
        case .tuesday:
            return ICAL_TUESDAY_WEEKDAY
        case .wednesday:
            return ICAL_WEDNESDAY_WEEKDAY
        case .thursday:
            return ICAL_THURSDAY_WEEKDAY
        case .friday:
            return ICAL_FRIDAY_WEEKDAY
        case .saturday:
            return ICAL_SATURDAY_WEEKDAY
        }
    }
}



extension Sequence where Element == Int {
    var libicalRecurrenceSequence: [Int16] {
        var elements = sorted().map { Int16($0) }
        elements.append(Int16(ICAL_RECURRENCE_ARRAY_MAX.rawValue))
        return elements
    }

    func copyToLibicalStruct<T>( foo: inout T) {
        withUnsafeMutableBytes(of: &foo) { (ptr) in
            ptr.bindMemory(to: Int16.self)
            let _ = ptr.initializeMemory(as: Int16.self, from: libicalRecurrenceSequence)
        }
    }
}

extension RecurranceRule: LibicalPropertyConvertible {


    func libicalProperty() -> LibicalProperty {
        var recurrence = icalrecurrencetype()
        recurrence.freq = frequency.icalFrequency
        recurrence.interval = Int16(interval)
        bySecond.copyToLibicalStruct(foo: &recurrence.by_second)
        byMinute.copyToLibicalStruct(foo: &recurrence.by_minute)
        byHour.copyToLibicalStruct(foo: &recurrence.by_hour)
        byDay.copyToLibicalStruct(foo: &recurrence.by_day)
        byMonthDay.copyToLibicalStruct(foo: &recurrence.by_month_day)
        byYearDay.copyToLibicalStruct(foo: &recurrence.by_year_day)
        byWeekNumber.copyToLibicalStruct(foo: &recurrence.by_week_no)
        byMonth.map({ $0.rawValue }).copyToLibicalStruct(foo: &recurrence.by_month)
        bySetpos.copyToLibicalStruct(foo: &recurrence.by_set_pos)
        return icalproperty_new_rrule(recurrence)
    }




}
