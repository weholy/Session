import SwiftUI

struct GlassActionButtonStyle: ButtonStyle {
    var tint: Color?

    func makeBody(configuration: Configuration) -> some View {
        let glass = tint.map { Glass.regular.tint($0).interactive() } ?? Glass.regular.interactive()

        return configuration.label
            .font(.controlLabel)
            .foregroundStyle(tint == nil ? Palette.textPrimary : Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .glassEffect(glass, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct GlassIconButtonStyle: ButtonStyle {
    var size: CGFloat = 44

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(Palette.textPrimary)
            .frame(width: size, height: size)
            .glassEffect(.regular.interactive(), in: Circle())
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassActionButtonStyle {
    static var glassAction: GlassActionButtonStyle { GlassActionButtonStyle() }
    static func glassAction(tint: Color) -> GlassActionButtonStyle { GlassActionButtonStyle(tint: tint) }
}
