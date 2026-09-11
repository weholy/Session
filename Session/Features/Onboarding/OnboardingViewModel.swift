import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class OnboardingViewModel {
    enum Phase {
        case intro
        case chat
        case building
        case done
    }

    struct Bubble: Identifiable {
        let id = UUID()
        let role: CoachRole
        var text: String
    }

    var phase: Phase = .intro
    var bubbles: [Bubble] = []
    var quickReplies: [String] = []
    var input = ""
    var coachTyping = false
    var buildingLine = "Собираю план"

    private var aiTranscript: [GroqMessage] = []
    private let scripted = ScriptedOnboarding()
    private var useAI: Bool
    private var pendingBrief: AthleteBrief?
    private var userTurns = 0
    private let maxTurns = 11

    private let context: ModelContext
    private let coach: AICoach
    private let plan: PlanService

    init(context: ModelContext, coach: AICoach = CoachEnvironment.live.coach) {
        self.context = context
        self.coach = coach
        self.plan = PlanService(context: context, coach: coach)
        self.useAI = coach.isAvailable
    }

    func begin() async {
        phase = .chat
        coachTyping = true
        defer { coachTyping = false }

        if useAI {
            do {
                let reply = try await coach.onboardingTurn(transcript: [.user("Начинай опрос.")])
                present(reply)
                return
            } catch {
                useAI = false
            }
        }
        present(scripted.start())
    }

    func send(_ text: String) async {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty, !coachTyping else { return }

        bubbles.append(.init(role: .user, text: clean))
        aiTranscript.append(.user(clean))
        quickReplies = []
        input = ""
        userTurns += 1
        coachTyping = true

        var reply: OnboardingReply
        if useAI {
            do {
                reply = try await coach.onboardingTurn(transcript: aiTranscript)
            } catch {
                useAI = false
                reply = scripted.reply(to: clean)
            }
        } else {
            reply = scripted.reply(to: clean)
        }

        if userTurns >= maxTurns, !reply.done {
            reply = OnboardingReply(message: "Понял, этого хватит. Собираю план.", quickReplies: [], done: true, brief: reply.brief ?? pendingBrief ?? fallbackBrief())
        }

        present(reply)
        coachTyping = false

        if reply.done {
            await finish(with: reply.brief ?? pendingBrief ?? fallbackBrief())
        }
    }

    private func present(_ reply: OnboardingReply) {
        if !reply.message.isEmpty {
            bubbles.append(.init(role: .coach, text: reply.message))
            aiTranscript.append(.assistant(reply.message))
        }
        quickReplies = reply.done ? [] : reply.quickReplies
        if let brief = reply.brief { pendingBrief = brief }
    }

    private func fallbackBrief() -> AthleteBrief {
        var brief = AthleteBrief.empty
        brief.experienceNote = "начальный уровень"
        brief.goalSummary = "стать сильнее к тесту"
        return brief
    }

    private func finish(with brief: AthleteBrief) async {
        phase = .building
        let lines = [
            "Считаю нагрузку по неделям",
            "Расставляю дни отдыха",
            "Подбираю упражнения под инвентарь",
            "Готовлю подводку к тесту"
        ]
        let ticker = Task { @MainActor in
            var i = 0
            while !Task.isCancelled {
                buildingLine = lines[i % lines.count]
                i += 1
                try? await Task.sleep(for: .seconds(2))
            }
        }

        let profile = AthleteProfile(
            displayName: brief.displayName,
            goalSummary: brief.goalSummary,
            experienceNote: brief.experienceNote,
            injuriesNote: brief.injuriesNote,
            trainingDaysPerWeek: brief.trainingDaysPerWeek,
            restWeekdays: brief.restWeekdays,
            sessionMinutes: brief.sessionMinutes,
            equipment: brief.equipmentValues,
            startDate: Date(),
            onboardingTranscript: transcriptData(),
            baseline: brief.baseline
        )
        context.insert(profile)

        let specs = SemesterCalendar.standardSemesters()
        for spec in specs {
            context.insert(Semester(index: spec.index, title: spec.title, startDate: spec.startDate, testDate: spec.testDate))
        }
        try? context.save()

        for spec in specs {
            await plan.buildSemester(spec, brief: brief)
        }

        let state = AppStateStore.load(in: context)
        state.onboardingComplete = true
        state.notificationsEnabled = true
        try? context.save()

        ticker.cancel()
        phase = .done
    }

    private func transcriptData() -> Data {
        let lines = bubbles.map { "\($0.role == .coach ? "Тренер" : "Я"): \($0.text)" }
        return (try? JSONEncoder().encode(lines)) ?? Data()
    }
}
