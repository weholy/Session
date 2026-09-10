import SwiftUI
import UIKit

struct SlideToConfirm: View {
    let title: String
    let action: () -> Void

    @State private var offset: CGFloat = 0
    @State private var confirmed = false

    private let knob: CGFloat = 56
    private let inset: CGFloat = 5

    var body: some View {
        GeometryReader { geo in
            let limit = max(geo.size.width - knob - inset * 2, 1)

            ZStack(alignment: .leading) {
                Capsule().fill(Palette.surface.opacity(0.7))

                Text(confirmed ? "Готово" : title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Palette.textSecondary)
                    .frame(maxWidth: .infinity)

                ZStack {
                    Circle().fill(Palette.accent)
                    Image(systemName: confirmed ? "checkmark" : "arrow.right")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: knob, height: knob)
                .offset(x: offset + inset)
                .gesture(drag(limit: limit))
            }
        }
        .frame(height: knob + inset * 2)
        .glassCard(cornerRadius: (knob + inset * 2) / 2)
    }

    private func drag(limit: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard !confirmed else { return }
                offset = min(max(value.translation.width, 0), limit)
            }
            .onEnded { _ in
                guard !confirmed else { return }
                if offset > limit * 0.85 {
                    confirmed = true
                    offset = limit
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    action()
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { offset = 0 }
                }
            }
    }
}
