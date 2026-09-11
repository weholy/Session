import SwiftUI
import SwiftData

struct CalendarHomeView: View {
    @Query(sort: \Semester.index) private var semesters: [Semester]
    @Query private var plans: [TrainingPlan]
    @State private var selectedMonth: Date?

    var body: some View {
        NavigationStack {
            ZStack {
                Palette.canvas.ignoresSafeArea()

                if months.isEmpty {
                    PlaceholderScreen(title: "Календарь", subtitle: "Появится после первого запуска онбординга")
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            header
                            ForEach(months, id: \.self) { month in
                                MonthCard(date: month, workoutCount: trainingCount(in: month)) {
                                    selectedMonth = month
                                }
                            }
                        }
                        .padding(16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedMonth) { month in
                MonthCalendarView(month: month)
            }
        }
    }

    private var header: some View {
        HStack {
            Text(yearLabel)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Palette.textSecondary)
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private var yearLabel: String {
        guard let first = months.first, let last = months.last else { return "" }
        let cal = Calendar.training
        let y1 = cal.component(.year, from: first)
        let y2 = cal.component(.year, from: last)
        return y1 == y2 ? "\(y1)" : "\(y1) — \(y2)"
    }

    private var months: [Date] {
        guard let first = semesters.first, let last = semesters.last else { return [] }
        let cal = Calendar.training
        guard var cursor = cal.dateInterval(of: .month, for: first.startDate)?.start else { return [] }
        let end = cal.dateInterval(of: .month, for: last.testDate)?.start ?? last.testDate
        var result: [Date] = []
        while cursor <= end {
            result.append(cursor)
            guard let next = cal.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    private func trainingCount(in month: Date) -> Int {
        guard let interval = Calendar.training.dateInterval(of: .month, for: month) else { return 0 }
        return plans.reduce(0) { total, plan in
            total + plan.days.filter { day in
                interval.contains(day.date) && (day.kind == .training || day.kind == .miniTest || day.kind == .test)
            }.count
        }
    }
}
