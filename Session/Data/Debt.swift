import Foundation
import SwiftData

struct DebtItem: Codable, Hashable {
    var catalogID: String
    var sets: Int
    var reps: Int
    var seconds: Int
}

@Model
final class Debt {
    var createdAt: Date
    var originDate: Date
    var severityFactor: Double
    var items: [DebtItem]
    var resolvedAt: Date?

    init(originDate: Date, severityFactor: Double, items: [DebtItem]) {
        self.createdAt = .now
        self.originDate = originDate
        self.severityFactor = severityFactor
        self.items = items
    }

    var isOpen: Bool { resolvedAt == nil }
}
