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
            .overlay {
                Capsule().stroke(.white.opacity(tint == nil ? 0.12 : 0.32), lineWidth: 1)
            }
            .shadow(color: .black.opacity(tint == nil ? 0 : 0.18), radius: 12, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct GlassIconButtonStyle: ButtonStyle {
    var size: CGFloat = 44
    var tint: Color?

    func makeBody(configuration: Configuration) -> some View {
        let glass = tint.map { Glass.regular.tint($0).interactive() } ?? Glass.regular.interactive()
        configuration.label
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(tint == nil ? Palette.textPrimary : Color.white)
            .frame(width: size, height: size)
            .glassEffect(glass, in: Circle())
            .overlay {
                Circle().stroke(.white.opacity(tint == nil ? 0.12 : 0.32), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassActionButtonStyle {
    static var glassAction: GlassActionButtonStyle { GlassActionButtonStyle() }
    static func glassAction(tint: Color) -> GlassActionButtonStyle { GlassActionButtonStyle(tint: tint) }
}
