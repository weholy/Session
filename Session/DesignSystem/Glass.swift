import SwiftUI

extension View {
    func glassCapsule(interactive: Bool = false) -> some View {
        glassEffect(interactive ? .regular.interactive() : .regular, in: Capsule())
            .overlay { Capsule().stroke(.white.opacity(0.14), lineWidth: 0.75) }
    }

    func glassCard(cornerRadius: CGFloat = 26, interactive: Bool = false) -> some View {
        glassEffect(
            interactive ? .regular.interactive() : .regular,
            in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(.white.opacity(0.14), lineWidth: 0.75)
        }
    }

    func glassCircle(interactive: Bool = false) -> some View {
        glassEffect(interactive ? .regular.interactive() : .regular, in: Circle())
            .overlay { Circle().stroke(.white.opacity(0.14), lineWidth: 0.75) }
    }
}
