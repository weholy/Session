import Foundation

enum DateText {
    private static let ruLocale = Locale(identifier: "ru_RU")

    static func monthName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = ruLocale
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date).capitalized(with: ruLocale)
    }

    static func weekdayShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = ruLocale
        formatter.dateFormat = "EEEEEE"
        return formatter.string(from: date).uppercased(with: ruLocale)
    }

    static func dayMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = ruLocale
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }

    static let mondayFirstSymbols = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"]
}
