import Foundation

struct SemesterSpec: Sendable, Hashable {
    var index: Int
    var title: String
    var startDate: Date
    var testDate: Date
    var isMaintenance: Bool

    var weekCount: Int {
        let days = Calendar.training.dateComponents([.day], from: startDate, to: testDate).day ?? 0
        return max(1, Int(ceil(Double(days) / 7.0)))
    }
}

extension Calendar {
    static let training: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2
        c.timeZone = .current
        return c
    }()
}

enum SemesterCalendar {
    static func standardSemesters(reference: Date = .now) -> [SemesterSpec] {
        let cal = Calendar.training
        let year = cal.component(.year, from: reference)
        let month = cal.component(.month, from: reference)

        let fallYear = month >= 8 ? year : year - 1
        let springYear = fallYear + 1

        let firstStart = max(cal.startOfDay(for: reference), date(fallYear, 9, 1))
        let firstTest = date(fallYear, 12, 22)
        let secondStart = date(springYear, 1, 12)
        let secondTest = date(springYear, 6, 22)

        var specs: [SemesterSpec] = []
        if reference < firstTest {
            specs.append(SemesterSpec(index: 1, title: "Первый семестр", startDate: firstStart, testDate: firstTest, isMaintenance: false))
        }
        specs.append(SemesterSpec(index: 2, title: "Второй семестр", startDate: secondStart, testDate: secondTest, isMaintenance: false))
        return specs
    }

    static func winterBreak(after first: SemesterSpec, before second: SemesterSpec) -> DateInterval? {
        let cal = Calendar.training
        let start = cal.date(byAdding: .day, value: 1, to: first.testDate) ?? first.testDate
        let end = cal.date(byAdding: .day, value: -1, to: second.startDate) ?? second.startDate
        guard end > start else { return nil }
        return DateInterval(start: cal.startOfDay(for: start), end: cal.startOfDay(for: end))
    }

    static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.training.date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }

    static func weekIndex(of day: Date, in semester: SemesterSpec) -> Int {
        let days = Calendar.training.dateComponents([.day], from: semester.startDate, to: day).day ?? 0
        return max(0, days / 7)
    }
}
