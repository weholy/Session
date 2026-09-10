import Foundation

enum PlanMapper {
    static func resolve(blueprint: PlanBlueprint, semester: SemesterSpec, base: ResolvedPlan) -> ResolvedPlan {
        let cal = Calendar.training
        let start = cal.startOfDay(for: semester.startDate)
        let end = cal.startOfDay(for: semester.testDate)
        let anchor = cal.dateInterval(of: .weekOfYear, for: start)?.start ?? start

        var byDate: [Date: ResolvedDay] = Dictionary(
            base.days.map { (cal.startOfDay(for: $0.date), $0) },
            uniquingKeysWith: { first, _ in first }
        )

        for week in blueprint.weeks {
            let weekStart = cal.date(byAdding: .day, value: (week.index - 1) * 7, to: anchor) ?? anchor
            for day in week.days {
                guard let date = cal.date(byAdding: .day, value: max(0, day.weekday - 1), to: weekStart) else { continue }
                let key = cal.startOfDay(for: date)
                guard key >= start, key <= end else { continue }
                if let existing = byDate[key], existing.kind == .test { continue }

                let kind = DayKind(rawValue: day.kind) ?? .training
                let exercises = day.exercises.enumerated().compactMap { index, item -> ResolvedExercise? in
                    guard ExerciseCatalog[item.exerciseId] != nil else { return nil }
                    return ResolvedExercise(
                        catalogID: item.exerciseId,
                        order: index,
                        sets: max(1, item.sets),
                        repsMin: max(0, item.repsMin),
                        repsMax: max(item.repsMin, item.repsMax),
                        holdSeconds: max(0, item.holdSeconds),
                        restSeconds: item.restSeconds > 0 ? item.restSeconds : 90,
                        note: item.note
                    )
                }

                byDate[key] = ResolvedDay(
                    date: key,
                    kind: kind,
                    title: day.title.isEmpty ? fallbackTitle(kind) : day.title,
                    focus: day.focus,
                    coachNote: day.coachNote,
                    weekIndex: week.index - 1,
                    exercises: kind == .rest ? [] : exercises
                )
            }
        }

        let merged = byDate.values.sorted { $0.date < $1.date }
        return ResolvedPlan(
            semesterIndex: semester.index,
            source: .ai,
            goalTargets: blueprint.goalTargets.isEmpty ? base.goalTargets : blueprint.goalTargets,
            periodization: blueprint.periodization.isEmpty ? base.periodization : blueprint.periodization,
            days: merged
        )
    }

    static func applyReview(_ weeks: [BlueprintWeek], to plan: ResolvedPlan, semester: SemesterSpec, from date: Date) -> ResolvedPlan {
        guard !weeks.isEmpty else { return plan }
        let blueprint = PlanBlueprint(goalTargets: plan.goalTargets, periodization: plan.periodization, weeks: weeks)
        let base = ResolvedPlan(
            semesterIndex: plan.semesterIndex,
            source: plan.source,
            goalTargets: plan.goalTargets,
            periodization: plan.periodization,
            days: plan.days.filter { $0.date < Calendar.training.startOfDay(for: date) }
        )
        let future = resolve(blueprint: blueprint, semester: semester, base: base)
        let kept = plan.days.filter { $0.date < Calendar.training.startOfDay(for: date) }
        let updated = future.days.filter { $0.date >= Calendar.training.startOfDay(for: date) }
        return ResolvedPlan(
            semesterIndex: plan.semesterIndex,
            source: .revision,
            goalTargets: plan.goalTargets,
            periodization: plan.periodization,
            days: (kept + updated).sorted { $0.date < $1.date }
        )
    }

    private static func fallbackTitle(_ kind: DayKind) -> String {
        switch kind {
        case .rest: "Отдых"
        case .test: "Контрольный тест"
        case .miniTest: "Мини-тест"
        case .maintenance: "Поддержание"
        case .training: "Тренировка"
        }
    }
}
