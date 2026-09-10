import Foundation

private extension KeyedDecodingContainer {
    func str(_ key: Key) -> String { (try? decodeIfPresent(String.self, forKey: key)) ?? "" }
    func int(_ key: Key, _ fallback: Int = 0) -> Int {
        if let v = try? decodeIfPresent(Int.self, forKey: key) { return v }
        if let d = try? decodeIfPresent(Double.self, forKey: key) { return Int(d) }
        return fallback
    }
    func dbl(_ key: Key, _ fallback: Double = 0) -> Double {
        if let v = try? decodeIfPresent(Double.self, forKey: key) { return v }
        if let i = try? decodeIfPresent(Int.self, forKey: key) { return Double(i) }
        return fallback
    }
    func bool(_ key: Key) -> Bool { (try? decodeIfPresent(Bool.self, forKey: key)) ?? false }
    func arr<T: Decodable>(_ key: Key, _ type: T.Type) -> [T] {
        (try? decodeIfPresent([T].self, forKey: key)) ?? []
    }
}

struct AthleteBrief: Codable, Sendable {
    var displayName: String
    var goalSummary: String
    var experienceNote: String
    var injuriesNote: String
    var trainingDaysPerWeek: Int
    var restWeekdays: [Int]
    var sessionMinutes: Int
    var equipment: [String]
    var baseline: [String: Double]
    var motivation: String

    static let empty = AthleteBrief(
        displayName: "", goalSummary: "", experienceNote: "", injuriesNote: "нет",
        trainingDaysPerWeek: 5, restWeekdays: [4, 7], sessionMinutes: 35,
        equipment: ["floor", "pullUpBar", "dipBars"], baseline: [:], motivation: ""
    )

    init(displayName: String, goalSummary: String, experienceNote: String, injuriesNote: String, trainingDaysPerWeek: Int, restWeekdays: [Int], sessionMinutes: Int, equipment: [String], baseline: [String: Double], motivation: String) {
        self.displayName = displayName
        self.goalSummary = goalSummary
        self.experienceNote = experienceNote
        self.injuriesNote = injuriesNote
        self.trainingDaysPerWeek = trainingDaysPerWeek
        self.restWeekdays = restWeekdays
        self.sessionMinutes = sessionMinutes
        self.equipment = equipment
        self.baseline = baseline
        self.motivation = motivation
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        displayName = c.str(.displayName)
        goalSummary = c.str(.goalSummary)
        experienceNote = c.str(.experienceNote)
        injuriesNote = c.str(.injuriesNote).isEmpty ? "нет" : c.str(.injuriesNote)
        trainingDaysPerWeek = min(6, max(2, c.int(.trainingDaysPerWeek, 5)))
        restWeekdays = c.arr(.restWeekdays, Int.self).isEmpty ? [4, 7] : c.arr(.restWeekdays, Int.self)
        sessionMinutes = min(90, max(12, c.int(.sessionMinutes, 35)))
        equipment = c.arr(.equipment, String.self).isEmpty ? ["floor"] : c.arr(.equipment, String.self)
        baseline = (try? c.decodeIfPresent([String: Double].self, forKey: .baseline)) ?? [:]
        motivation = c.str(.motivation)
    }

    var equipmentValues: [Equipment] { equipment.compactMap(Equipment.init(rawValue:)) }
}

struct OnboardingReply: Codable, Sendable {
    var message: String
    var quickReplies: [String]
    var done: Bool
    var brief: AthleteBrief?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        message = c.str(.message)
        quickReplies = c.arr(.quickReplies, String.self)
        done = c.bool(.done)
        brief = try? c.decodeIfPresent(AthleteBrief.self, forKey: .brief)
    }

    init(message: String, quickReplies: [String], done: Bool, brief: AthleteBrief?) {
        self.message = message
        self.quickReplies = quickReplies
        self.done = done
        self.brief = brief
    }
}

struct BlueprintExercise: Codable, Sendable {
    var exerciseId: String
    var sets: Int
    var repsMin: Int
    var repsMax: Int
    var holdSeconds: Int
    var restSeconds: Int
    var note: String

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        exerciseId = c.str(.exerciseId)
        sets = max(1, c.int(.sets, 3))
        repsMin = c.int(.repsMin)
        repsMax = c.int(.repsMax)
        holdSeconds = c.int(.holdSeconds)
        restSeconds = c.int(.restSeconds, 90)
        note = c.str(.note)
    }
}

struct BlueprintDay: Codable, Sendable {
    var weekday: Int
    var kind: String
    var title: String
    var focus: String
    var coachNote: String
    var exercises: [BlueprintExercise]

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        weekday = min(7, max(1, c.int(.weekday, 1)))
        kind = c.str(.kind).isEmpty ? "training" : c.str(.kind)
        title = c.str(.title)
        focus = c.str(.focus)
        coachNote = c.str(.coachNote)
        exercises = c.arr(.exercises, BlueprintExercise.self)
    }
}

struct BlueprintWeek: Codable, Sendable {
    var index: Int
    var focus: String
    var days: [BlueprintDay]

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        index = max(1, c.int(.index, 1))
        focus = c.str(.focus)
        days = c.arr(.days, BlueprintDay.self)
    }

    init(index: Int, focus: String, days: [BlueprintDay]) {
        self.index = index
        self.focus = focus
        self.days = days
    }
}

struct GoalTarget: Codable, Sendable, Hashable {
    var exerciseId: String
    var value: Double
    var unit: String

    init(exerciseId: String, value: Double, unit: String) {
        self.exerciseId = exerciseId
        self.value = value
        self.unit = unit
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        exerciseId = c.str(.exerciseId)
        value = c.dbl(.value)
        unit = c.str(.unit).isEmpty ? "reps" : c.str(.unit)
    }
}

struct PlanBlueprint: Codable, Sendable {
    var goalTargets: [GoalTarget]
    var periodization: String
    var weeks: [BlueprintWeek]

    init(goalTargets: [GoalTarget], periodization: String, weeks: [BlueprintWeek]) {
        self.goalTargets = goalTargets
        self.periodization = periodization
        self.weeks = weeks
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        goalTargets = c.arr(.goalTargets, GoalTarget.self)
        periodization = c.str(.periodization)
        weeks = c.arr(.weeks, BlueprintWeek.self)
    }
}

struct WeeklyContext: Sendable {
    var weekIndex: Int
    var weeksToTest: Int
    var answers: [String: String]
    var planned: [String: Int]
    var completed: [String: Int]
    var missedDays: Int
    var upcomingWeeks: [BlueprintWeek]
}

struct ReviewOutcome: Codable, Sendable {
    var verdict: String
    var summary: String
    var adjustment: String
    var revisedWeeks: [BlueprintWeek]

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let raw = c.str(.verdict).lowercased()
        verdict = ["good", "ok", "weak"].contains(raw) ? raw : "ok"
        summary = c.str(.summary)
        adjustment = c.str(.adjustment)
        revisedWeeks = c.arr(.revisedWeeks, BlueprintWeek.self)
    }
}

struct TestEntrySpec: Codable, Sendable {
    var exerciseId: String
    var value: Double
    var unit: String
}
