import SwiftUI

struct ProgressCapsule: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.hairline)
                Capsule()
                    .fill(Palette.accent)
                    .frame(width: geo.size.width * clamped)
            }
        }
    }

    private var clamped: Double { min(max(progress, 0), 1) }
}

struct CountdownHeader: View {
    let daysLeft: Int
    let caption: String
    let progress: Double

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 4) {
                Text("\(daysLeft)")
                    .font(.display(72))
                    .foregroundStyle(Palette.textPrimary)
                    .contentTransition(.numericText())
                Text(caption)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Palette.textSecondary)
            }
            ProgressCapsule(progress: progress)
                .frame(height: 6)
                .padding(.horizontal, 44)
        }
    }
}

struct SectionHeader: View {
    let title: String
    var trailing: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.sectionTitle)
                .foregroundStyle(Palette.textPrimary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(Palette.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Palette.textPrimary)
        }
        .padding(.vertical, 12)
    }
}
