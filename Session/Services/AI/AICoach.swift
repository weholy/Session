import Foundation

protocol AICoach: Sendable {
    var isAvailable: Bool { get }

    func onboardingTurn(transcript: [GroqMessage]) async throws -> OnboardingReply
    func generatePlan(brief: AthleteBrief, semester: SemesterSpec, priorTest: [TestEntrySpec]) async throws -> PlanBlueprint
    func reviewWeek(context: WeeklyContext, brief: AthleteBrief) async throws -> ReviewOutcome
    func chat(thread: CoachThread, history: [GroqMessage], context: String) async throws -> String
    func explain(exercise: Exercise, question: String) async throws -> String
}

struct CoachEnvironment: Sendable {
    let coach: AICoach

    static let live: CoachEnvironment = {
        let client = GroqClient(apiKey: AppSecrets.groqKey)
        return CoachEnvironment(coach: GroqCoach(client: client))
    }()
}
