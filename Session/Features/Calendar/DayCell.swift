import SwiftUI

struct DayCell: View {
    let date: Date
    let day: PlannedDay?
    let isToday: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text("\(Calendar.training.component(.day, from: date))")
                    .font(.system(size: 15, weight: isToday ? .bold : .medium))
                    .foregroundStyle(.white)
                Circle()
                    .fill(dotColor)
                    .frame(width: 5, height: 5)
                    .opacity(day == nil ? 0 : 1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(day?.status == .done ? 0.14 : 0.06))
            }
            .overlay {
                if isToday {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(day == nil)
    }

    private var dotColor: Color {
        switch day?.kind {
        case .training, .maintenance: Palette.accent
        case .test, .miniTest: .orange
        case .rest: Color.white.opacity(0.3)
        case nil: .clear
        }
    }
}
