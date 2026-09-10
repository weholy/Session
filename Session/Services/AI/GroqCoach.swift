import Foundation

struct GroqCoach: AICoach {
    let client: GroqClient

    var isAvailable: Bool { client.apiKey?.isEmpty == false }

    func onboardingTurn(transcript: [GroqMessage]) async throws -> OnboardingReply {
        var messages: [GroqMessage] = [.system(Prompts.onboardingSystem())]
        messages.append(contentsOf: transcript)
        let raw = try await client.complete(
            model: .conversation,
            messages: messages,
            json: true,
            temperature: 0.5,
            maxTokens: 900,
            reasoning: .low
        )
        return try client.decodeJSON(OnboardingReply.self, from: raw)
    }

    func generatePlan(brief: AthleteBrief, semester: SemesterSpec, priorTest: [TestEntrySpec]) async throws -> PlanBlueprint {
        let priorText: String
        if priorTest.isEmpty {
            priorText = "Контрольных тестов ещё не было."
        } else {
            priorText = "Последний тест: " + priorTest.map { "\($0.exerciseId) \(Int($0.value)) \($0.unit)" }.joined(separator: ", ")
        }

        let user = """
        Человек: \(brief.displayName.isEmpty ? "без имени" : brief.displayName).
        Цель: \(brief.goalSummary).
        Уровень: \(brief.experienceNote). baseline: \(briefBaseline(brief)).
        Травмы: \(brief.injuriesNote).
        Тренировок в неделю: \(brief.trainingDaysPerWeek). Минут на тренировку: \(brief.sessionMinutes).
        Инвентарь: \(brief.equipment.joined(separator: ", ")).
        \(priorText)
        Составь план на \(semester.weekCount) недель.
        """

        let raw = try await client.complete(
            model: .planning,
            messages: [
                .system(Prompts.planSystem(
                    weekCount: semester.weekCount,
                    restWeekdays: brief.restWeekdays,
                    maintenance: semester.isMaintenance
                )),
                .user(user)
            ],
            json: true,
            temperature: 0.4,
            maxTokens: 16000,
            reasoning: .medium
        )
        return try client.decodeJSON(PlanBlueprint.self, from: raw)
    }

    func reviewWeek(context: WeeklyContext, brief: AthleteBrief) async throws -> ReviewOutcome {
        let planned = context.planned.map { "\($0.key): план \($0.value), факт \(context.completed[$0.key] ?? 0)" }.joined(separator: "\n")
        let answers = context.answers.map { "\($0.key) — \($0.value)" }.joined(separator: "\n")
        let upcoming = (try? JSONEncoder().encode(context.upcomingWeeks))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"

        let user = """
        Неделя \(context.weekIndex). До теста недель: \(context.weeksToTest). Пропущено дней: \(context.missedDays).
        Объём план/факт:
        \(planned)
        Ответы:
        \(answers)
        Ближайшие недели (обнови при необходимости):
        \(upcoming)
        """

        let raw = try await client.complete(
            model: .planning,
            messages: [.system(Prompts.reviewSystem()), .user(user)],
            json: true,
            temperature: 0.4,
            maxTokens: 6000,
            reasoning: .medium
        )
        return try client.decodeJSON(ReviewOutcome.self, from: raw)
    }

    func chat(thread: CoachThread, history: [GroqMessage], context: String) async throws -> String {
        var messages: [GroqMessage] = [.system(Prompts.chatSystem(thread))]
        if !context.isEmpty { messages.append(.system(context)) }
        messages.append(contentsOf: history)
        return try await client.complete(
            model: .conversation,
            messages: messages,
            json: false,
            temperature: 0.6,
            maxTokens: 700,
            reasoning: .low
        )
    }

    func explain(exercise: Exercise, question: String) async throws -> String {
        try await client.complete(
            model: .conversation,
            messages: [
                .system(Prompts.chatSystem(.technique)),
                .system(Prompts.explainContext(exercise)),
                .user(question.isEmpty ? "Разбери технику подробнее." : question)
            ],
            json: false,
            temperature: 0.5,
            maxTokens: 600,
            reasoning: .low
        )
    }

    private func briefBaseline(_ brief: AthleteBrief) -> String {
        brief.baseline.map { "\($0.key)=\(Int($0.value))" }.joined(separator: ", ")
    }
}
