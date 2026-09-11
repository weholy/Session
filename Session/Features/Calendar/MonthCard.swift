import SwiftUI

struct MonthCard: View {
    let date: Date
    let workoutCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topLeading) {
                PhotoBackdrop(name: Photo.month(Calendar.training.component(.month, from: date)), darkening: 0.7, scrimStart: 0.3)

                VStack(alignment: .leading, spacing: 0) {
                    Text(countLabel)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .glassCapsule()

                    Spacer()

                    Text(DateText.monthName(date))
                        .font(.display(50))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .padding(18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var countLabel: String {
        workoutCount == 0 ? "Отдых" : "\(workoutCount) \(workoutWord(workoutCount))"
    }

    private func workoutWord(_ n: Int) -> String {
        let mod10 = n % 10, mod100 = n % 100
        if mod10 == 1, mod100 != 11 { return "тренировка" }
        if (2...4).contains(mod10), !(12...14).contains(mod100) { return "тренировки" }
        return "тренировок"
    }
}
