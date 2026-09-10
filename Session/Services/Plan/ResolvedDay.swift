import Foundation

struct ResolvedExercise: Sendable, Hashable {
    var catalogID: String
    var order: Int
    var sets: Int
    var repsMin: Int
    var repsMax: Int
    var holdSeconds: Int
    var restSeconds: Int
    var note: String
}

struct ResolvedDay: Sendable, Hashable {
    var date: Date
    var kind: DayKind
    var title: String
    var focus: String
    var coachNote: String
    var weekIndex: Int
    var exercises: [ResolvedExercise]
}

struct ResolvedPlan: Sendable {
    var semesterIndex: Int
    var source: PlanSource
    var goalTargets: [GoalTarget]
    var periodization: String
    var days: [ResolvedDay]
}
