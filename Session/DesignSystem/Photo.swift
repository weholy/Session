import SwiftUI

enum Photo {
    static func month(_ month: Int) -> String { String(format: "month_%02d", month) }

    static let cardPull = "card_pull"
    static let cardPush = "card_push"
    static let cardCore = "card_core"
    static let cardLegs = "card_legs"
    static let cardRest = "card_rest"
    static let cardFull = "card_full"
    static let heroOnboarding = "hero_onboarding"
    static let testDay = "test_day"

    static func card(for category: ExerciseCategory) -> String {
        switch category {
        case .pull: cardPull
        case .push: cardPush
        case .legs: cardLegs
        case .core: cardCore
        case .conditioning, .mobility: cardFull
        }
    }

    static func session(focus: ExerciseCategory?) -> String {
        guard let focus else { return cardFull }
        return card(for: focus)
    }

    static func forDay(kind: DayKind, exercises: [Exercise]) -> String {
        switch kind {
        case .rest: return cardRest
        case .test, .miniTest: return testDay
        case .training, .maintenance:
            guard !exercises.isEmpty else { return cardFull }
            var counts: [ExerciseCategory: Int] = [:]
            for exercise in exercises { counts[exercise.category, default: 0] += 1 }
            return card(for: counts.max(by: { $0.value < $1.value })?.key ?? .conditioning)
        }
    }
}

struct PhotoBackdrop: View {
    let name: String
    var darkening: Double = 0.8
    var scrimStart: Double = 0.4

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0), location: 0),
                        .init(color: .black.opacity(0.05), location: scrimStart),
                        .init(color: .black.opacity(darkening), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .clipped()
    }
}
