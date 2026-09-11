import SwiftUI

struct SetRow: View {
    let index: Int
    let isTimed: Bool
    let defaultValue: Int
    let logged: SetLog?
    let onComplete: (Int) -> Void

    @State private var value: Int

    init(index: Int, isTimed: Bool, defaultValue: Int, logged: SetLog?, onComplete: @escaping (Int) -> Void) {
        self.index = index
        self.isTimed = isTimed
        self.defaultValue = defaultValue
        self.logged = logged
        self.onComplete = onComplete
        _value = State(initialValue: logged.map { isTimed ? $0.seconds : $0.reps } ?? defaultValue)
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("Подход \(index)")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.textPrimary)

            Spacer()

            stepButton(symbol: "minus") { value = max(0, value - 1) }

            Text("\(value)\(isTimed ? " сек" : "")")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Palette.textPrimary)
                .frame(minWidth: 46)
                .contentTransition(.numericText())
                .animation(.default, value: value)

            stepButton(symbol: "plus") { value += 1 }

            Button {
                onComplete(value)
            } label: {
                Image(systemName: logged != nil ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(GlassIconButtonStyle(size: 36, tint: logged != nil ? Palette.accent : nil))
        }
        .padding(12)
        .glassCard(cornerRadius: 16)
    }

    private func stepButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
        }
        .buttonStyle(GlassIconButtonStyle(size: 30))
    }
}
