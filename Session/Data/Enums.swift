import Foundation

enum DayKind: String, Codable, CaseIterable {
    case training
    case rest
    case test
    case miniTest
    case maintenance
}

enum DayStatus: String, Codable {
    case pending
    case done
    case partial
    case skipped
}

enum PlanSource: String, Codable {
    case ai
    case fallback
    case revision
}

enum LoadUnit: String, Codable {
    case reps
    case seconds
}

enum Equipment: String, Codable, CaseIterable {
    case floor
    case pullUpBar
    case dipBars
    case bands
    case weights
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case pull
    case push
    case legs
    case core
    case conditioning
    case mobility
}

enum ReviewVerdict: String, Codable {
    case good
    case ok
    case weak
}

enum CoachRole: String, Codable {
    case user
    case coach
}

enum CoachThread: String, Codable {
    case onboarding
    case weekly
    case technique
    case free
}

enum TestKind: String, Codable {
    case semester
    case mini
}
