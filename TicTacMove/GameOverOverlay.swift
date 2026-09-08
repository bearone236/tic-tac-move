import SwiftUI

/// A themed, in-scene game-over card replacing the system alert.
struct GameOverOverlay: View {
    let winner: Player?
    let onPlayAgain: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 18) {
                Text("ゲーム終了")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))

                if let winner {
                    Text(winner.rawValue)
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.markColor(for: winner))
                        .shadow(color: Theme.markColor(for: winner), radius: 18)

                    Text("\(winner.rawValue) の勝ち！")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }

                Button(action: onPlayAgain) {
                    Text("もう一度")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                .padding(.top, 6)
            }
            .padding(28)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.06, green: 0.05, blue: 0.13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Theme.cardStroke, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 30)
            )
        }
    }
}

#Preview {
    GameOverOverlay(winner: .x) {}
}
