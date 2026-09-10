import SwiftUI

struct PlaceholderScreen: View {
    let title: String
    var subtitle = "Раздел появится на следующем шаге"

    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()
            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.textPrimary)
                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(32)
        }
    }
}
