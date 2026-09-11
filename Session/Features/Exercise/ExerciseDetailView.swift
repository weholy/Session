import SwiftUI
import SwiftData
import AudioToolbox
import UIKit

struct ExerciseDetailView: View {
    let prescribed: PlannedExercise

    @Environment(\.modelContext) private var context
    @State private var restRemaining: Int?
    @State private var timerTask: Task<Void, Never>?

    private var exercise: Exercise? { ExerciseCatalog[prescribed.catalogID] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                statsRow
                setLogger
                if let restRemaining {
                    restBanner(restRemaining)
                }
                if let exercise {
                    muscles(exercise)
                    techniqueSteps(exercise)
                    mistakesSection(exercise)
                    breathing(exercise)
                }
            }
            .padding(Metrics.screenPadding)
            .padding(.bottom, 30)
        }
        .background(Palette.canvas.ignoresSafeArea())
        .onDisappear { timerTask?.cancel() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise?.categoryTitle ?? "")
                .font(.caption)
                .foregroundStyle(Palette.accent)
            Text(exercise?.name ?? prescribed.catalogID)
                .font(.display(26))
                .foregroundStyle(Palette.textPrimary)
        }
        .padding(.top, 8)
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statTile(title: "Подходы", value: "\(prescribed.sets)")
            statTile(
                title: prescribed.isTimed ? "Держать" : "Повторы",
                value: prescribed.isTimed ? "\(prescribed.holdSeconds) сек" : repsLabel
            )
            statTile(title: "Отдых", value: "\(prescribed.restSeconds) сек")
        }
    }

    private func statTile(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 17, weight: .bold)).foregroundStyle(Palette.textPrimary)
            Text(title).font(.system(size: 12)).foregroundStyle(Palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassCard(cornerRadius: Metrics.tileRadius)
    }

    private var repsLabel: String {
        prescribed.targetRepsMin == prescribed.targetRepsMax
            ? "\(prescribed.targetRepsMax)"
            : "\(prescribed.targetRepsMin)–\(prescribed.targetRepsMax)"
    }

    private var setLogger: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Подходы")
            VStack(spacing: 8) {
                ForEach(1...max(1, prescribed.sets), id: \.self) { index in
                    SetRow(
                        index: index,
                        isTimed: prescribed.isTimed,
                        defaultValue: prescribed.isTimed ? prescribed.holdSeconds : prescribed.targetRepsMax,
                        logged: log(for: index)
                    ) { value in
                        logSet(index: index, value: value)
                    }
                }
            }
        }
    }

    private func log(for index: Int) -> SetLog? {
        prescribed.logs.first { $0.setIndex == index }
    }

    private func logSet(index: Int, value: Int) {
        if let existing = log(for: index) {
            if prescribed.isTimed { existing.seconds = value } else { existing.reps = value }
            existing.completedAt = .now
        } else {
            let entry = SetLog(setIndex: index, reps: prescribed.isTimed ? 0 : value, seconds: prescribed.isTimed ? value : 0)
            entry.exercise = prescribed
            context.insert(entry)
        }
        try? context.save()
        if index < prescribed.sets {
            startRest()
        }
    }

    private func startRest() {
        timerTask?.cancel()
        let total = max(5, prescribed.restSeconds)
        restRemaining = total
        timerTask = Task { @MainActor in
            var remaining = total
            while remaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                remaining -= 1
                restRemaining = remaining
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AudioServicesPlaySystemSound(1057)
            restRemaining = nil
        }
    }

    private func restBanner(_ seconds: Int) -> some View {
        HStack {
            Image(systemName: "timer")
                .foregroundStyle(Palette.accent)
            Text("Отдых: \(seconds) сек")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Palette.textPrimary)
            Spacer()
            Button("Пропустить") {
                timerTask?.cancel()
                restRemaining = nil
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Palette.accent)
        }
        .padding(14)
        .glassCard(cornerRadius: Metrics.tileRadius)
    }

    private func muscles(_ exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Работают")
            FlowLayout(spacing: 8) {
                ForEach(exercise.primaryMuscles + exercise.secondaryMuscles, id: \.self) { muscle in
                    Text(muscle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Palette.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .glassCapsule()
                }
            }
        }
    }

    private func techniqueSteps(_ exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Как делать")
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(exercise.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Palette.accent))
                        Text(step)
                            .font(.system(size: 15))
                            .foregroundStyle(Palette.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func mistakesSection(_ exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Частые ошибки")
            VStack(alignment: .leading, spacing: 8) {
                ForEach(exercise.mistakes, id: \.self) { mistake in
                    HStack(alignment: .top, spacing: 10) {
                        Circle().fill(Color.orange).frame(width: 5, height: 5).padding(.top, 7)
                        Text(mistake)
                            .font(.system(size: 14))
                            .foregroundStyle(Palette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func breathing(_ exercise: Exercise) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Rectangle().fill(Palette.accent).frame(width: 3)
            Text(exercise.breathing)
                .font(.system(size: 14))
                .foregroundStyle(Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 2)
    }
}
