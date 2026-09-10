import SwiftUI

struct RootView: View {
    @State private var tab: AppTab = .today

    var body: some View {
        TabView(selection: $tab) {
            Tab("Календарь", systemImage: "square.grid.2x2", value: AppTab.calendar) {
                CalendarHomeView()
            }
            Tab("Сегодня", systemImage: "bolt.fill", value: AppTab.today) {
                TodayView()
            }
            Tab("Прогресс", systemImage: "chart.xyaxis.line", value: AppTab.progress) {
                ProgressDashboardView()
            }
            Tab("Профиль", systemImage: "person.fill", value: AppTab.profile) {
                ProfileView()
            }
        }
        .tint(Palette.accent)
    }
}
