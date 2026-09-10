import Foundation

enum FallbackPlanBuilder {
    static func build(brief: AthleteBrief, semester: SemesterSpec) -> ResolvedPlan {
        let cal = Calendar.training
        let equipment = Set(brief.equipmentValues)
        let restDays = Set(brief.restWeekdays)
        let splits = splitRotation(daysPerWeek: brief.trainingDaysPerWeek)

        var days: [ResolvedDay] = []
        var cursor = cal.startOfDay(for: semester.startDate)
        let end = cal.startOfDay(for: semester.testDate)
        let totalWeeks = semester.weekCount
        var trainingIndexInWeek = 0
        var lastWeek = -1

        while cursor <= end {
            let weekIndex = SemesterCalendar.weekIndex(of: cursor, in: semester)
            if weekIndex != lastWeek { trainingIndexInWeek = 0; lastWeek = weekIndex }
            let weekday = cal.component(.weekday, from: cursor).mondayFirst

            if cal.isDate(cursor, inSameDayAs: end) {
                days.append(testDay(date: cursor, weekIndex: weekIndex))
            } else if restDays.contains(weekday) || semester.isMaintenance && trainingIndexInWeek >= 3 {
                days.append(restDay(date: cursor, weekIndex: weekIndex))
            } else {
                let split = splits[trainingIndexInWeek % splits.count]
                let isDeload = weekIndex % 4 == 3 && weekIndex != 0
                let isTaper = weekIndex >= totalWeeks - 1
                let isMini = trainingIndexInWeek == 0 && [4, 8, 12].contains(weekIndex)

                if isMini {
                    days.append(miniTestDay(date: cursor, weekIndex: weekIndex))
                } else {
                    days.append(trainingDay(
                        date: cursor,
                        weekIndex: weekIndex,
                        split: split,
                        equipment: equipment,
                        baseline: brief.baseline,
                        minutes: brief.sessionMinutes,
                        deload: isDeload,
                        taper: isTaper,
                        maintenance: semester.isMaintenance
                    ))
                }
                trainingIndexInWeek += 1
            }
            cursor = cal.date(byAdding: .day, value: 1, to: cursor) ?? end.addingTimeInterval(86400)
        }

        return ResolvedPlan(
            semesterIndex: semester.index,
            source: .fallback,
            goalTargets: defaultTargets(baseline: brief.baseline, weeks: totalWeeks),
            periodization: "Рост нагрузки по неделям, каждая четвёртая — разгрузка, последняя — подводка к тесту.",
            days: days
        )
    }

    private static func splitRotation(daysPerWeek: Int) -> [[ExerciseCategory]] {
        switch daysPerWeek {
        case ...3: return [[.pull, .push, .core], [.legs, .core], [.pull, .push, .conditioning]]
        case 4: return [[.pull, .core], [.push, .legs], [.pull, .push], [.legs, .core]]
        case 5: return [[.pull, .core], [.push, .legs], [.pull, .core], [.push, .legs], [.conditioning, .core]]
        default: return [[.pull, .core], [.push, .legs], [.pull, .core], [.push, .legs], [.legs, .conditioning], [.pull, .push]]
        }
    }

    private static func trainingDay(
        date: Date,
        weekIndex: Int,
        split: [ExerciseCategory],
        equipment: Set<Equipment>,
        baseline: [String: Double],
        minutes: Int,
        deload: Bool,
        taper: Bool,
        maintenance: Bool
    ) -> ResolvedDay {
        var factor = 1.0 + 0.05 * Double(weekIndex)
        if deload { factor *= 0.6 }
        if taper { factor *= 0.55 }
        if maintenance { factor = 0.7 }

        let sets = maintenance ? 2 : (deload ? 3 : (weekIndex >= 4 ? 4 : 3))
        let budget = max(2, min(5, minutes / 8))

        var picks: [ResolvedExercise] = []
        var order = 0
        for category in split {
            let perCategory = max(1, budget / split.count)
            for exercise in pickExercises(category: category, equipment: equipment, weekIndex: weekIndex, count: perCategory) {
                picks.append(prescription(for: exercise, order: order, sets: sets, factor: factor, baseline: baseline, weekIndex: weekIndex))
                order += 1
            }
        }

        let focusText = split.map(categoryTitle).joined(separator: " · ")
        return ResolvedDay(
            date: date,
            kind: .training,
            title: dayTitle(for: split),
            focus: focusText,
            coachNote: coachNote(weekIndex: weekIndex, deload: deload, taper: taper),
            weekIndex: weekIndex,
            exercises: picks
        )
    }

    private static func pickExercises(category: ExerciseCategory, equipment: Set<Equipment>, weekIndex: Int, count: Int) -> [Exercise] {
        let usable = ExerciseCatalog.inCategory(category).filter { exercise in
            exercise.equipment.allSatisfy { $0 == .floor || equipment.contains($0) }
        }
        guard !usable.isEmpty else { return [] }

        let ranked = usable.sorted { lhs, rhs in
            difficulty(lhs) < difficulty(rhs)
        }
        let window = min(ranked.count, max(count + 1, 2))
        let start = min(max(0, weekIndex / 3), max(0, ranked.count - window))
        let slice = Array(ranked[start..<min(ranked.count, start + window)])
        return Array(slice.prefix(count))
    }

    private static func prescription(for exercise: Exercise, order: Int, sets: Int, factor: Double, baseline: [String: Double], weekIndex: Int) -> ResolvedExercise {
        if exercise.unit == .seconds {
            let base = baseline[exercise.id] ?? defaultHold(exercise)
            let hold = Int((base * factor).rounded())
            return ResolvedExercise(
                catalogID: exercise.id,
                order: order,
                sets: sets,
                repsMin: 0,
                repsMax: 0,
                holdSeconds: max(15, hold),
                restSeconds: 75,
                note: exercise.tempo
            )
        } else {
            let base = baseline[exercise.id] ?? defaultReps(exercise)
            let target = max(3, Int((base * factor).rounded()))
            return ResolvedExercise(
                catalogID: exercise.id,
                order: order,
                sets: sets,
                repsMin: max(1, target - 2),
                repsMax: target + 2,
                holdSeconds: 0,
                restSeconds: exercise.category == .pull ? 120 : 90,
                note: weekIndex >= 4 ? "Добавь повтор, если последний подход даётся легко" : exercise.tempo
            )
        }
    }

    private static func miniTestDay(date: Date, weekIndex: Int) -> ResolvedDay {
        ResolvedDay(
            date: date,
            kind: .miniTest,
            title: "Мини-тест",
            focus: "Подтягивания · Отжимания · Планка",
            coachNote: "Разомнись и выложись по максимуму в одном подходе.",
            weekIndex: weekIndex,
            exercises: [
                ResolvedExercise(catalogID: "pullup", order: 0, sets: 1, repsMin: 0, repsMax: 0, holdSeconds: 0, restSeconds: 180, note: "Максимум повторов"),
                ResolvedExercise(catalogID: "pushup", order: 1, sets: 1, repsMin: 0, repsMax: 0, holdSeconds: 0, restSeconds: 180, note: "Максимум повторов"),
                ResolvedExercise(catalogID: "plank", order: 2, sets: 1, repsMin: 0, repsMax: 0, holdSeconds: 0, restSeconds: 0, note: "Держи до отказа")
            ]
        )
    }

    private static func testDay(date: Date, weekIndex: Int) -> ResolvedDay {
        ResolvedDay(
            date: date,
            kind: .test,
            title: "Контрольный тест",
            focus: "Итог семестра",
            coachNote: "Проверяем, куда пришли. Замеряем максимум по каждому упражнению.",
            weekIndex: weekIndex,
            exercises: [
                ResolvedExercise(catalogID: "pullup", order: 0, sets: 1, repsMin: 0, repsMax: 0, holdSeconds: 0, restSeconds: 180, note: "Максимум"),
                ResolvedExercise(catalogID: "pushup", order: 1, sets: 1, repsMin: 0, repsMax: 0, holdSeconds: 0, restSeconds: 180, note: "Максимум"),
                ResolvedExercise(catalogID: "squat", order: 2, sets: 1, repsMin: 0, repsMax: 0, holdSeconds: 0, restSeconds: 180, note: "Максимум за 2 минуты"),
                ResolvedExercise(catalogID: "plank", order: 3, sets: 1, repsMin: 0, repsMax: 0, holdSeconds: 0, restSeconds: 0, note: "До отказа")
            ]
        )
    }

    private static func restDay(date: Date, weekIndex: Int) -> ResolvedDay {
        ResolvedDay(
            date: date,
            kind: .rest,
            title: "Отдых",
            focus: "Восстановление",
            coachNote: restNote(weekIndex: weekIndex),
            weekIndex: weekIndex,
            exercises: []
        )
    }

    private static func defaultTargets(baseline: [String: Double], weeks: Int) -> [GoalTarget] {
        let growth = 1.0 + 0.9 * (Double(weeks) / 15.0)
        func target(_ id: String, _ fallback: Double, _ unit: String) -> GoalTarget {
            let base = max(baseline[id] ?? fallback, fallback)
            return GoalTarget(exerciseId: id, value: (base * growth).rounded(), unit: unit)
        }
        return [
            target("pullup", 3, "reps"),
            target("pushup", 15, "reps"),
            target("squat", 30, "reps"),
            target("plank", 45, "seconds")
        ]
    }

    private static func difficulty(_ e: Exercise) -> Int {
        var score = e.easier.count * 2 - e.harder.count
        if e.id.contains("negative") || e.id.contains("knee") || e.id.contains("incline") { score -= 3 }
        if e.id.contains("archer") || e.id.contains("pistol") || e.id.contains("pike") || e.id.contains("nordic") { score += 4 }
        return score
    }

    private static func defaultReps(_ e: Exercise) -> Double {
        switch e.category {
        case .pull: return 5
        case .push: return 10
        case .legs: return 14
        case .core: return 12
        case .conditioning: return 16
        case .mobility: return 10
        }
    }

    private static func defaultHold(_ e: Exercise) -> Double {
        e.id.contains("plank") ? 30 : 25
    }

    private static func categoryTitle(_ c: ExerciseCategory) -> String {
        switch c {
        case .pull: "Спина"
        case .push: "Грудь и плечи"
        case .legs: "Ноги"
        case .core: "Кор"
        case .conditioning: "Кардио"
        case .mobility: "Мобилити"
        }
    }

    private static func dayTitle(for split: [ExerciseCategory]) -> String {
        if split.contains(.pull) && split.contains(.core) { return "Тяга и кор" }
        if split.contains(.push) && split.contains(.legs) { return "Жим и ноги" }
        if split.contains(.conditioning) { return "Круговая" }
        if split.contains(.pull) && split.contains(.push) { return "Верх тела" }
        return "Тренировка"
    }

    private static func coachNote(weekIndex: Int, deload: Bool, taper: Bool) -> String {
        if taper { return "Подводка. Работай чисто, не гонись за числами." }
        if deload { return "Разгрузка. Меньше объём — восстанавливаемся под следующий рывок." }
        if weekIndex == 0 { return "Первая неделя. Ставим технику, к весу вернёмся." }
        if weekIndex >= 8 { return "Середина пути. Держи темп, добавляй по повтору где можешь." }
        return "Рабочая неделя. Последний подход — близко к отказу."
    }

    private static func restNote(weekIndex: Int) -> String {
        let notes = [
            "Отдых. Поспи нормально и попей воды.",
            "День без нагрузки. Можно лёгкая растяжка.",
            "Восстановление. Мышцы растут сегодня, а не на тренировке.",
            "Пауза. Завтра снова работаем."
        ]
        return notes[weekIndex % notes.count]
    }
}

extension Int {
    var mondayFirst: Int {
        let shifted = self - 1
        return shifted == 0 ? 7 : shifted
    }
}
