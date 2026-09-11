import SwiftUI
import SwiftData

struct TodayView: View {
    @Query(sort: \Semester.index) private var semesters: [Semester]
    @Query private var plans: [TrainingPlan]
    @State private var selectedDay: PlannedDay?

    var body: some View {
        NavigationStack {
            ZStack {
                Palette.canvas.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: Metrics.sectionGap) {
                        if let semester = activeSemester {
                            CountdownHeader(
                                daysLeft: daysLeft(to: semester),
                                caption: caption(for: semester),
                                progress: progress(in: semester)
                            )
                            .padding(.top, 24)
                        }

                        if let day = todayPlan {
                            TodayWorkoutCard(day: day) { selectedDay = day }
                            if day.kind != .rest {
                                Button(day.status == .done ? "Тренировка выполнена" : "Начать тренировку") {
                                    selectedDay = day
                                }
                                .buttonStyle(.glassAction(tint: Palette.accent))
                            }
                        } else {
                            emptyState
                        }
                    }
                    .padding(.horizontal, Metrics.screenPadding)
                    .padding(.bottom, 40)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedDay) { day in
                WorkoutDayView(day: day)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("План ещё не готов")
                .font(.cardTitle)
                .foregroundStyle(Palette.textPrimary)
            Text("Пройди опрос в профиле, чтобы тренер собрал план")
                .font(.system(size: 14))
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }

    private var activeSemester: Semester? {
        let today = Date().dayKey
        if let current = semesters.first(where: { $0.startDate.dayKey <= today && today <= $0.testDate.dayKey }) {
            return current
        }
        return semesters.first(where: { $0.startDate.dayKey > today }) ?? semesters.last
    }

    private var todayPlan: PlannedDay? {
        guard let semester = activeSemester else { return nil }
        let key = Date().dayKey
        return plans.first { $0.semesterIndex == semester.index }?.days.first { $0.date.dayKey == key }
    }

    private func daysLeft(to semester: Semester) -> Int {
        max(0, Calendar.training.dateComponents([.day], from: Date().dayKey, to: semester.testDate.dayKey).day ?? 0)
    }

    private func caption(for semester: Semester) -> String {
        "до теста · \(semester.title.lowercased())"
    }

    private func progress(in semester: Semester) -> Double {
        let total = Calendar.training.dateComponents([.day], from: semester.startDate.dayKey, to: semester.testDate.dayKey).day ?? 1
        let elapsed = Calendar.training.dateComponents([.day], from: semester.startDate.dayKey, to: Date().dayKey).day ?? 0
        guard total > 0 else { return 0 }
        return Double(min(max(elapsed, 0), total)) / Double(total)
    }
}

private struct TodayWorkoutCard: View {
    let day: PlannedDay
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                PhotoBackdrop(
                    name: Photo.forDay(kind: day.kind, exercises: catalogExercises),
                    darkening: 0.8,
                    scrimStart: 0.35
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(badge)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .glassCapsule()
                    Spacer(minLength: 0)
                    Text(day.title)
                        .font(.display(24))
                        .foregroundStyle(.white)
                    if !day.focus.isEmpty {
                        Text(day.focus)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .frame(height: 208)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var badge: String {
        day.kind == .rest ? "День отдыха" : "\(day.orderedExercises.count) упражнений"
    }

    private var catalogExercises: [Exercise] {
        day.orderedExercises.compactMap { ExerciseCatalog[$0.catalogID] }
    }
}
