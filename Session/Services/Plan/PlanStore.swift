import Foundation
import SwiftData

@MainActor
enum PlanStore {
    static func install(_ plan: ResolvedPlan, into context: ModelContext, preservingBefore cutoff: Date? = nil) {
        let semesterIndex = plan.semesterIndex
        let descriptor = FetchDescriptor<TrainingPlan>(
            predicate: #Predicate { $0.semesterIndex == semesterIndex }
        )
        let existing = (try? context.fetch(descriptor)) ?? []

        var priorState: [Date: (DayStatus, Date?)] = [:]
        var priorRevision = 0
        for old in existing {
            priorRevision = max(priorRevision, old.revision)
            for day in old.days {
                priorState[day.date.dayKey] = (day.status, day.completedAt)
            }
            context.delete(old)
        }

        let model = TrainingPlan(
            semesterIndex: semesterIndex,
            source: plan.source,
            revision: priorRevision + 1,
            periodization: plan.periodization,
            goalTargets: plan.goalTargets
        )
        context.insert(model)

        let cutoffKey = cutoff.map { $0.dayKey }

        for resolved in plan.days {
            let key = resolved.date.dayKey
            let day = PlannedDay(
                date: key,
                kind: resolved.kind,
                title: resolved.title,
                focus: resolved.focus,
                coachNote: resolved.coachNote,
                weekIndex: resolved.weekIndex
            )
            day.plan = model

            if let (status, completedAt) = priorState[key],
               let cutoffKey, key < cutoffKey {
                day.status = status
                day.completedAt = completedAt
            }

            context.insert(day)

            for item in resolved.exercises {
                let exercise = PlannedExercise(
                    catalogID: item.catalogID,
                    order: item.order,
                    sets: item.sets,
                    targetRepsMin: item.repsMin,
                    targetRepsMax: item.repsMax,
                    holdSeconds: item.holdSeconds,
                    restSeconds: item.restSeconds,
                    note: item.note
                )
                exercise.day = day
                context.insert(exercise)
            }
        }

        try? context.save()
    }

    static func currentPlan(semesterIndex: Int, in context: ModelContext) -> TrainingPlan? {
        let descriptor = FetchDescriptor<TrainingPlan>(
            predicate: #Predicate { $0.semesterIndex == semesterIndex },
            sortBy: [SortDescriptor(\.revision, order: .reverse)]
        )
        return try? context.fetch(descriptor).first
    }
}

extension Date {
    var dayKey: Date { Calendar.training.startOfDay(for: self) }
}
