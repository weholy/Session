import SwiftUI

struct ExerciseRow: View {
    let prescribed: PlannedExercise
    let onTap: () -> Void

    private var exercise: Exercise? { ExerciseCatalog[prescribed.catalogID] }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Palette.surface)
                    Image(systemName: symbol)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Palette.accent)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(exercise?.name ?? prescribed.catalogID)
                        .font(.rowTitle)
                        .foregroundStyle(Palette.textPrimary)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.textSecondary)
                }

                Spacer()

                Text("\(prescribed.completedSets)/\(prescribed.sets)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(prescribed.completedSets >= prescribed.sets ? Palette.accent : Palette.textSecondary)
            }
            .padding(12)
            .glassCard(cornerRadius: Metrics.tileRadius)
        }
        .buttonStyle(.plain)
    }

    private var symbol: String {
        switch exercise?.category {
        case .pull: "figure.strengthtraining.traditional"
        case .push: "figure.strengthtraining.functional"
        case .legs: "figure.walk"
        case .core: "figure.core.training"
        case .conditioning: "figure.run"
        case .mobility: "figure.flexibility"
        case nil: "dumbbell"
        }
    }

    private var subtitle: String {
        if prescribed.isTimed {
            return "\(prescribed.sets) × \(prescribed.holdSeconds) сек"
        }
        let range = prescribed.targetRepsMin == prescribed.targetRepsMax
            ? "\(prescribed.targetRepsMax)"
            : "\(prescribed.targetRepsMin)–\(prescribed.targetRepsMax)"
        return "\(prescribed.sets) × \(range)"
    }
}
