import Foundation
import SwiftData

@Model
final class TrainingPlan {
    var semesterIndex: Int
    var generatedAt: Date
    var source: PlanSource
    var revision: Int

    @Relationship(deleteRule: .cascade, inverse: \PlannedDay.plan)
    var days: [PlannedDay]

    init(semesterIndex: Int, source: PlanSource, revision: Int = 1) {
        self.semesterIndex = semesterIndex
        self.generatedAt = .now
        self.source = source
        self.revision = revision
        self.days = []
    }
}

@Model
final class PlannedDay {
    var date: Date
    var kind: DayKind
    var title: String
    var focus: String
    var coachNote: String
    var weekIndex: Int
    var status: DayStatus
    var completedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \PlannedExercise.day)
    var exercises: [PlannedExercise]

    var plan: TrainingPlan?

    init(
        date: Date,
        kind: DayKind,
        title: String,
        focus: String = "",
        coachNote: String = "",
        weekIndex: Int = 0
    ) {
        self.date = date
        self.kind = kind
        self.title = title
        self.focus = focus
        self.coachNote = coachNote
        self.weekIndex = weekIndex
        self.status = .pending
        self.exercises = []
    }

    var orderedExercises: [PlannedExercise] {
        exercises.sorted { $0.order < $1.order }
    }
}

@Model
final class PlannedExercise {
    var catalogID: String
    var order: Int
    var sets: Int
    var targetRepsMin: Int
    var targetRepsMax: Int
    var holdSeconds: Int
    var restSeconds: Int
    var note: String
    var isDebtPortion: Bool

    @Relationship(deleteRule: .cascade, inverse: \SetLog.exercise)
    var logs: [SetLog]

    var day: PlannedDay?

    init(
        catalogID: String,
        order: Int,
        sets: Int,
        targetRepsMin: Int = 0,
        targetRepsMax: Int = 0,
        holdSeconds: Int = 0,
        restSeconds: Int = 90,
        note: String = "",
        isDebtPortion: Bool = false
    ) {
        self.catalogID = catalogID
        self.order = order
        self.sets = sets
        self.targetRepsMin = targetRepsMin
        self.targetRepsMax = targetRepsMax
        self.holdSeconds = holdSeconds
        self.restSeconds = restSeconds
        self.note = note
        self.isDebtPortion = isDebtPortion
        self.logs = []
    }

    var isTimed: Bool { holdSeconds > 0 }

    var completedSets: Int {
        Set(logs.map(\.setIndex)).count
    }
}

@Model
final class SetLog {
    var setIndex: Int
    var reps: Int
    var seconds: Int
    var completedAt: Date

    var exercise: PlannedExercise?

    init(setIndex: Int, reps: Int = 0, seconds: Int = 0) {
        self.setIndex = setIndex
        self.reps = reps
        self.seconds = seconds
        self.completedAt = .now
    }
}
