import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var states: [AppState]

    var body: some View {
        Group {
            if states.first?.onboardingComplete == true {
                MainTabsView()
            } else {
                OnboardingView(context: context)
            }
        }
    }
}
