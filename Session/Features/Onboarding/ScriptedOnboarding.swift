import Foundation

@MainActor
final class ScriptedOnboarding {
    private var step = 0
    private var brief = AthleteBrief.empty

    private struct Step {
        let message: String
        let quickReplies: [String]
        let apply: (String, inout AthleteBrief) -> Void
    }

    private let steps: [Step] = [
        Step(message: "Привет. Я помогу собрать план до контрольного теста. Пара вопросов — и начнём. Как тебя звать?",
             quickReplies: ["Пропустить"]) { answer, brief in
            if answer.lowercased() != "пропустить" { brief.displayName = answer.trimmingCharacters(in: .whitespaces) }
        },
        Step(message: "Что есть дома?",
             quickReplies: ["Турник и брусья", "Только турник", "Только пол"]) { answer, brief in
            switch answer {
            case "Только турник": brief.equipment = ["floor", "pullUpBar"]
            case "Только пол": brief.equipment = ["floor", "bands"]
            default: brief.equipment = ["floor", "pullUpBar", "dipBars"]
            }
        },
        Step(message: "Сколько раз подтянешься за один подход сейчас?",
             quickReplies: ["0", "1–3", "4–7", "8 и больше"]) { answer, brief in
            brief.baseline["pullup"] = [ "0": 0.0, "1–3": 2.0, "4–7": 5.0, "8 и больше": 9.0 ][answer] ?? 2
        },
        Step(message: "А отжиманий от пола за подход?",
             quickReplies: ["До 10", "10–20", "20–35", "Больше 35"]) { answer, brief in
            brief.baseline["pushup"] = [ "До 10": 8.0, "10–20": 15.0, "20–35": 27.0, "Больше 35": 40.0 ][answer] ?? 12
        },
        Step(message: "Сколько держишь планку на предплечьях?",
             quickReplies: ["До 30 сек", "30–60 сек", "1–2 минуты", "Дольше"]) { answer, brief in
            brief.baseline["plank"] = [ "До 30 сек": 25.0, "30–60 сек": 45.0, "1–2 минуты": 90.0, "Дольше": 150.0 ][answer] ?? 40
        },
        Step(message: "Сколько дней в неделю готов заниматься?",
             quickReplies: ["3", "4", "5", "6"]) { answer, brief in
            brief.trainingDaysPerWeek = Int(answer.prefix(1)) ?? 5
        },
        Step(message: "Сколько времени на одну тренировку?",
             quickReplies: ["15–20 мин", "30 мин", "45 мин", "Час и больше"]) { answer, brief in
            brief.sessionMinutes = [ "15–20 мин": 18, "30 мин": 30, "45 мин": 45, "Час и больше": 60 ][answer] ?? 35
        },
        Step(message: "Что-нибудь беспокоит — плечи, спина, колени, запястья?",
             quickReplies: ["Ничего", "Плечи", "Спина", "Колени"]) { answer, brief in
            brief.injuriesNote = answer == "Ничего" ? "нет" : answer
        },
        Step(message: "И последнее. Что хочешь получить к тесту?",
             quickReplies: ["Максимум подтягиваний и отжиманий", "Стать заметно сильнее"]) { answer, brief in
            brief.goalSummary = answer
            brief.motivation = answer
        }
    ]

    func start() -> OnboardingReply {
        step = 0
        return OnboardingReply(message: steps[0].message, quickReplies: steps[0].quickReplies, done: false, brief: nil)
    }

    func reply(to answer: String) -> OnboardingReply {
        if step < steps.count {
            steps[step].apply(answer, &brief)
        }
        step += 1
        if step < steps.count {
            return OnboardingReply(message: steps[step].message, quickReplies: steps[step].quickReplies, done: false, brief: nil)
        }
        finalizeRestDays()
        return OnboardingReply(message: "Готово. Собираю план.", quickReplies: [], done: true, brief: brief)
    }

    private func finalizeRestDays() {
        switch brief.trainingDaysPerWeek {
        case ...3: brief.restWeekdays = [2, 4, 6, 7]
        case 4: brief.restWeekdays = [3, 6, 7]
        case 5: brief.restWeekdays = [4, 7]
        default: brief.restWeekdays = [7]
        }
        if brief.experienceNote.isEmpty {
            let pull = Int(brief.baseline["pullup"] ?? 0)
            let push = Int(brief.baseline["pushup"] ?? 0)
            let plank = Int(brief.baseline["plank"] ?? 0)
            brief.experienceNote = "подтягивания \(pull), отжимания \(push), планка \(plank) сек"
        }
    }
}
