import SwiftUI
import SwiftData

struct MonthCalendarView: View {
    let month: Date

    @Query private var plans: [TrainingPlan]
    @Namespace private var zoom
    @State private var selectedDay: PlannedDay?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text(DateText.monthName(month))
                        .font(.display(36))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    weekdayHeader

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(Array(weeks.enumerated()), id: \.offset) { _, date in
                            if let date, let plannedDay = daysByDate[date.dayKey] {
                                DayCell(date: date, day: plannedDay, isToday: Calendar.training.isDateInToday(date)) {
                                    selectedDay = plannedDay
                                }
                                .matchedTransitionSource(id: plannedDay.id, in: zoom)
                            } else if let date {
                                DayCell(date: date, day: nil, isToday: false) {}
                            } else {
                                Color.clear.frame(height: 52)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    legend
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(item: $selectedDay) { day in
            WorkoutDayView(day: day)
                .navigationTransition(.zoom(sourceID: day.id, in: zoom))
        }
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(DateText.mondayFirstSymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
    }

    private var legend: some View {
        HStack(spacing: 16) {
            legendItem(color: Palette.accent, label: "Тренировка")
            legendItem(color: .orange, label: "Тест")
            legendItem(color: .white.opacity(0.3), label: "Отдых")
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.system(size: 12)).foregroundStyle(.white.opacity(0.6))
        }
    }

    private var weeks: [Date?] {
        let cal = Calendar.training
        guard let interval = cal.dateInterval(of: .month, for: month) else { return [] }
        let firstWeekday = cal.component(.weekday, from: interval.start).mondayFirst
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        var cursor = interval.start
        while cursor < interval.end {
            days.append(cursor)
            guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    private var daysByDate: [Date: PlannedDay] {
        Dictionary(
            plans.flatMap(\.days).map { ($0.date.dayKey, $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }
}
