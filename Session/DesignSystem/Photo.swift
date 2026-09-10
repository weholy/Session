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
}

struct PhotoBackdrop: View {
    let name: String
    var darkening: Double = 0.72

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(darkening * 0.2), .black.opacity(darkening)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
    }
}
