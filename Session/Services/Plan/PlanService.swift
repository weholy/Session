import Foundation
import Observation
import SwiftData

extension ResolvedPlan {
    @MainActor
    init(persisted plan: TrainingPlan) {
        self.init(
            semesterIndex: plan.semesterIndex,
            source: plan.source,
            goalTargets: plan.goalTargets,
            periodization: plan.periodization,
            days: plan.days
                .sorted { $0.date < $1.date }
                .map { day in
                    ResolvedDay(
                        date: day.date,
                        kind: day.kind,
                        title: day.title,
                        focus: day.focus,
                        coachNote: day.coachNote,
                        weekIndex: day.weekIndex,
                        exercises: day.orderedExercises.map { exercise in
                            ResolvedExercise(
                                catalogID: exercise.catalogID,
                                order: exercise.order,
                                sets: exercise.sets,
                                repsMin: exercise.targetRepsMin,
                                repsMax: exercise.targetRepsMax,
                                holdSeconds: exercise.holdSeconds,
                                restSeconds: exercise.restSeconds,
                                note: exercise.note
                            )
                        }
                    )
                }
        )
    }
}

@MainActor
@Observable
final class PlanService {
    private let context: ModelContext
    private let coach: AICoach

    var isWorking = false
    var lastError: String?

    init(context: ModelContext, coach: AICoach = CoachEnvironment.live.coach) {
        self.context = context
        self.coach = coach
    }

    func buildSemester(_ semester: SemesterSpec, brief: AthleteBrief, priorTest: [TestEntrySpec] = []) async {
        isWorking = true
        defer { isWorking = false }

        let fallback = FallbackPlanBuilder.build(brief: brief, semester: semester)
        PlanStore.install(fallback, into: context)

        guard coach.isAvailable else {
            setSyncFailed(true)
            return
        }

        do {
            let blueprint = try await coach.generatePlan(brief: brief, semester: semester, priorTest: priorTest)
            let resolved = PlanMapper.resolve(blueprint: blueprint, semester: semester, base: fallback)
            PlanStore.install(resolved, into: context, preservingBefore: Date())
            setSyncFailed(false)
        } catch {
            lastError = String(describing: error)
            setSyncFailed(true)
        }
    }

    func applyReview(_ outcome: ReviewOutcome, semester: SemesterSpec) {
        guard !outcome.revisedWeeks.isEmpty,
              let plan = PlanStore.currentPlan(semesterIndex: semester.index, in: context) else { return }
        let current = ResolvedPlan(persisted: plan)
        let updated = PlanMapper.applyReview(outcome.revisedWeeks, to: current, semester: semester, from: Date())
        PlanStore.install(updated, into: context, preservingBefore: Date())
    }

    private func setSyncFailed(_ failed: Bool) {
        let state = AppStateStore.load(in: context)
        state.planSyncFailed = failed
        try? context.save()
    }
}
