import Foundation
import SwiftData

@Model
final class WeeklyReview {
    var weekStart: Date
    var createdAt: Date
    var answers: Data
    var verdict: ReviewVerdict
    var summary: String
    var adjustment: String

    init(
        weekStart: Date,
        answers: Data,
        verdict: ReviewVerdict,
        summary: String,
        adjustment: String
    ) {
        self.weekStart = weekStart
        self.createdAt = .now
        self.answers = answers
        self.verdict = verdict
        self.summary = summary
        self.adjustment = adjustment
    }
}

struct TestEntry: Codable, Hashable {
    var catalogID: String
    var value: Double
    var unit: LoadUnit
}

@Model
final class TestResult {
    var kind: TestKind
    var date: Date
    var semesterIndex: Int
    var entries: [TestEntry]
    var aiSummary: String

    init(
        kind: TestKind,
        date: Date,
        semesterIndex: Int,
        entries: [TestEntry],
        aiSummary: String = ""
    ) {
        self.kind = kind
        self.date = date
        self.semesterIndex = semesterIndex
        self.entries = entries
        self.aiSummary = aiSummary
    }
}

@Model
final class PersonalRecord {
    var catalogID: String
    var value: Double
    var unit: LoadUnit
    var achievedAt: Date

    init(catalogID: String, value: Double, unit: LoadUnit, achievedAt: Date = .now) {
        self.catalogID = catalogID
        self.value = value
        self.unit = unit
        self.achievedAt = achievedAt
    }
}
