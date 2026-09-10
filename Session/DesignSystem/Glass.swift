import SwiftUI

extension View {
    func glassCapsule(interactive: Bool = false) -> some View {
        glassEffect(interactive ? .regular.interactive() : .regular, in: Capsule())
    }

    func glassCard(cornerRadius: CGFloat = 26, interactive: Bool = false) -> some View {
        glassEffect(
            interactive ? .regular.interactive() : .regular,
            in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
    }

    func glassCircle(interactive: Bool = false) -> some View {
        glassEffect(interactive ? .regular.interactive() : .regular, in: Circle())
    }
}
