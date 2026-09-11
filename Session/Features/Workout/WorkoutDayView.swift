import SwiftUI
import SwiftData

struct WorkoutDayView: View {
    let day: PlannedDay

    @Environment(\.modelContext) private var context
    @State private var selectedExercise: PlannedExercise?

    var body: some View {
        ZStack(alignment: .bottom) {
            Palette.canvas.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    banner
                    infoCard
                    if day.kind == .rest {
                        restNote
                    } else {
                        exercisesSection
                    }
                }
                .padding(.bottom, day.kind == .rest ? 40 : 110)
            }

            if day.kind != .rest {
                SlideToConfirm(title: day.status == .done ? "Тренировка выполнена" : "Завершить тренировку") {
                    completeDay()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseDetailView(prescribed: exercise)
        }
    }

    private var banner: some View {
        ZStack(alignment: .bottomLeading) {
            PhotoBackdrop(
                name: Photo.forDay(kind: day.kind, exercises: catalogExercises),
                darkening: 0.8,
                scrimStart: 0.3
            )
            VStack(alignment: .leading, spacing: 6) {
                Text(DateText.dayMonth(day.date))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))
                Text(day.title)
                    .font(.display(28))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                if !day.focus.isEmpty {
                    Text(day.focus)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
            .padding(20)
        }
        .frame(height: 220)
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            InfoRow(title: "Статус", value: statusText)
            if !day.coachNote.isEmpty {
                Rectangle().fill(Palette.hairline).frame(height: 1)
                Text(day.coachNote)
                    .font(.system(size: 14))
                    .foregroundStyle(Palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
            }
        }
        .padding(.horizontal, 14)
        .glassCard(cornerRadius: Metrics.cardRadius)
        .padding(.horizontal, Metrics.screenPadding)
    }

    private var restNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Отдых")
            Text("Мышцы растут во время восстановления, а не на тренировке. Завтра снова в графике.")
                .font(.system(size: 15))
                .foregroundStyle(Palette.textSecondary)
        }
        .padding(.horizontal, Metrics.screenPadding)
    }

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Упражнения", trailing: "\(completedCount)/\(day.orderedExercises.count)")
            VStack(spacing: 10) {
                ForEach(day.orderedExercises) { exercise in
                    ExerciseRow(prescribed: exercise) { selectedExercise = exercise }
                }
            }
        }
        .padding(.horizontal, Metrics.screenPadding)
    }

    private var catalogExercises: [Exercise] {
        day.orderedExercises.compactMap { ExerciseCatalog[$0.catalogID] }
    }

    private var completedCount: Int {
        day.orderedExercises.filter { $0.completedSets >= $0.sets }.count
    }

    private var statusText: String {
        switch day.status {
        case .done: "Выполнено"
        case .partial: "Частично"
        case .skipped: "Пропущено"
        case .pending: day.date.dayKey < Date().dayKey ? "Просрочено" : "Ещё не начато"
        }
    }

    private func completeDay() {
        day.status = .done
        day.completedAt = .now
        try? context.save()
    }
}
