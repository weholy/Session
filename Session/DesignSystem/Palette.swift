import SwiftUI
import UIKit

enum Palette {
    static let accent = Color.accentColor

    static let canvas = dynamic(light: 0xF5F5F7, dark: 0x0A0A0C)
    static let surface = dynamic(light: 0xFFFFFF, dark: 0x161619)
    static let elevated = dynamic(light: 0xFFFFFF, dark: 0x1F1F26)
    static let textPrimary = dynamic(light: 0x0C0C0F, dark: 0xF7F7FA)
    static let textSecondary = dynamic(light: 0x6B6B73, dark: 0x9A9AA4)
    static let hairline = dynamic(light: 0xE4E4E9, dark: 0x2A2A31)

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(rgb: dark) : UIColor(rgb: light)
        })
    }
}

private extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
