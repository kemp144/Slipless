import SwiftUI

struct ProgressShareCard: View {
    let title: String
    let streakText: String
    let urgesWon: Int
    let slipsLogged: Int
    let moneySavedText: String?
    let timeSavedText: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.12, blue: 0.20),
                    Color(red: 0.10, green: 0.20, blue: 0.28),
                    Color(red: 0.18, green: 0.24, blue: 0.40)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Slipless")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))

                    Text(title)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Still showing up. Still moving forward.")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.80))
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Current streak")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.75))

                    Text(streakText)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(28)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                HStack(spacing: 18) {
                    shareStat(title: "Urges won", value: "\(urgesWon)")
                    shareStat(title: "Slips logged", value: "\(slipsLogged)")
                }

                if let moneySavedText {
                    shareHighlight(title: "Money saved", value: moneySavedText)
                }

                if let timeSavedText {
                    shareHighlight(title: "Time reclaimed", value: timeSavedText)
                }
            }
            .padding(42)
        }
        .frame(width: 1080, height: 1350)
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
    }

    func shareStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundColor(Color.white.opacity(0.75))

            Text(value)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    func shareHighlight(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundColor(Color.white.opacity(0.70))

            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}