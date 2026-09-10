import SwiftUI

struct TodayView: View {
    @State private var route: TodayRoute?

    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Metrics.sectionGap) {
                    CountdownHeader(daysLeft: 103, caption: "до зимнего теста", progress: 0.12)
                        .padding(.top, 24)

                    TodayWorkoutCard(
                        badge: "5 упражнений · ~35 мин",
                        title: "Тренировка дня",
                        focus: "Подтягивания · Отжимания · Кор"
                    ) {
                        route = .workout
                    }

                    Button("Начать тренировку") { route = .workout }
                        .buttonStyle(.glassAction(tint: Palette.accent))
                }
                .padding(.horizontal, Metrics.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .sheet(item: $route) { destination in
            switch destination {
            case .workout:
                StagePlaceholderSheet(text: "Экран тренировки — шаг 6")
            }
        }
    }
}

private enum TodayRoute: String, Identifiable {
    case workout
    var id: String { rawValue }
}

private struct TodayWorkoutCard: View {
    let badge: String
    let title: String
    let focus: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                PhotoBackdrop(name: Photo.cardPull)

                VStack(alignment: .leading, spacing: 8) {
                    Text(badge)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .glassCapsule()
                    Spacer(minLength: 0)
                    Text(title)
                        .font(.display(24))
                        .foregroundStyle(.white)
                    Text(focus)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.78))
                }
                .padding(18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .frame(height: 208)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct StagePlaceholderSheet: View {
    let text: String

    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()
            Text(text)
                .font(.cardTitle)
                .foregroundStyle(Palette.textSecondary)
        }
        .presentationDetents([.medium])
    }
}
