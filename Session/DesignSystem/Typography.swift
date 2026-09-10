import SwiftUI

extension Font {
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static let screenTitle = Font.system(size: 30, weight: .bold, design: .rounded)
    static let sectionTitle = Font.system(size: 20, weight: .semibold)
    static let cardTitle = Font.system(size: 17, weight: .semibold)
    static let rowTitle = Font.system(size: 16, weight: .medium)
    static let controlLabel = Font.system(size: 17, weight: .semibold)
    static let caption = Font.system(size: 13, weight: .medium)
}
