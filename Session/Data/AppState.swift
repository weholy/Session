import Foundation
import SwiftData

@Model
final class AppState {
    var onboardingComplete: Bool
    var currentStreak: Int
    var longestStreak: Int
    var streakFrozen: Bool
    var lastCountedDate: Date?
    var consecutiveMisses: Int
    var lastReviewDate: Date?
    var lastEngineRun: Date?
    var notificationsEnabled: Bool
    var reminderHour: Int
    var planSyncFailed: Bool

    init() {
        self.onboardingComplete = false
        self.currentStreak = 0
        self.longestStreak = 0
        self.streakFrozen = false
        self.consecutiveMisses = 0
        self.notificationsEnabled = true
        self.reminderHour = 19
        self.planSyncFailed = false
    }
}
