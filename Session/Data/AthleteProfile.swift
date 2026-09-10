import Foundation
import SwiftData

@Model
final class AthleteProfile {
    var createdAt: Date
    var displayName: String
    var goalSummary: String
    var experienceNote: String
    var injuriesNote: String
    var trainingDaysPerWeek: Int
    var restWeekdays: [Int]
    var sessionMinutes: Int
    var equipment: [Equipment]
    var startDate: Date
    var onboardingTranscript: Data
    var baseline: [String: Double]

    init(
        displayName: String = "",
        goalSummary: String = "",
        experienceNote: String = "",
        injuriesNote: String = "",
        trainingDaysPerWeek: Int = 5,
        restWeekdays: [Int] = [5, 1],
        sessionMinutes: Int = 35,
        equipment: [Equipment] = [.floor, .pullUpBar, .dipBars],
        startDate: Date = .now,
        onboardingTranscript: Data = Data(),
        baseline: [String: Double] = [:]
    ) {
        self.createdAt = .now
        self.displayName = displayName
        self.goalSummary = goalSummary
        self.experienceNote = experienceNote
        self.injuriesNote = injuriesNote
        self.trainingDaysPerWeek = trainingDaysPerWeek
        self.restWeekdays = restWeekdays
        self.sessionMinutes = sessionMinutes
        self.equipment = equipment
        self.startDate = startDate
        self.onboardingTranscript = onboardingTranscript
        self.baseline = baseline
    }
}
