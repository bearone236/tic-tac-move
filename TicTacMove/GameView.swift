import SwiftUI
import UIKit

struct GameView: View {
    @ObservedObject var engine: GameEngine
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            AmbientBackground()

            VStack(spacing: 24) {
                topBar
                header
                BoardView(engine: engine)
                    .padding(.horizontal, 20)
                Spacer(minLength: 0)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)

            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: engine.currentPlayer) { _ in
            triggerAIIfNeeded()
        }
        .onChange(of: engine.selectedIndex) { newValue in
            if newValue != nil { SoundPlayer.shared.play(.select) }
        }
        .onChange(of: engine.board) { _ in
            SoundPlayer.shared.play(.piece)
        }
        .onChange(of: engine.winner) { winner in
            guard winner != nil else { return }
            celebrateWin()
        }
        .onAppear {
            SoundPlayer.shared.startBGM()
            triggerAIIfNeeded()
        }
        .onDisappear {
            SoundPlayer.shared.stopBGM()
        }
        .alert(
            "ゲーム終了",
            isPresented: Binding(
                get: { engine.isGameOver },
                set: { _ in }
            )
        ) {
            Button("もう一度") {
                withAnimation {
                    showConfetti = false
                    engine.reset()
                }
            }
        } message: {
            if let winner = engine.winner {
                Text("\(winner.rawValue) の勝ちです！")
            }
        }
    }

    private var topBar: some View {
        HStack {
            circleButton(systemImage: "chevron.left") { dismiss() }
            Spacer()
            Menu {
                Button {
                    withAnimation { engine.resetScores() }
                } label: {
                    Label("スコアをリセット", systemImage: "arrow.counterclockwise.circle")
                }
                NavigationLink {
                    HowToPlayView()
                } label: {
                    Label("遊び方", systemImage: "questionmark.circle")
                }
            } label: {
                circleButtonLabel(systemImage: "ellipsis")
            }
        }
        .padding(.horizontal, 20)
    }

    private func circleButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            circleButtonLabel(systemImage: systemImage)
        }
    }

    private func circleButtonLabel(systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(Circle().fill(Theme.cardFill))
            .overlay(Circle().stroke(Theme.cardStroke, lineWidth: 1))
    }

    private func triggerAIIfNeeded() {
        guard engine.isCPUOpponent, !engine.isHumanTurn, !engine.isGameOver else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                engine.performAIMove()
            }
        }
    }

    private func celebrateWin() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        SoundPlayer.shared.play(.win)
        withAnimation { showConfetti = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { showConfetti = false }
        }
    }

    private var header: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                scoreChip(for: .x)
                scoreChip(for: .o)
            }

            statusBadge
        }
    }

    private func scoreChip(for player: Player) -> some View {
        let tint = Theme.markColor(for: player)
        return HStack(spacing: 8) {
            Text(player.rawValue)
                .font(.headline.bold())
            Text("\(player == .x ? engine.scoreX : engine.scoreO)")
                .font(.headline.monospacedDigit())
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(tint.opacity(0.16)))
        .overlay(Capsule().stroke(tint.opacity(0.4), lineWidth: 1))
    }

    private var statusBadge: some View {
        Text(phaseDescription)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white.opacity(0.75))
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(Theme.cardFill))
            .overlay(Capsule().stroke(Theme.cardStroke, lineWidth: 1))
            .frame(minHeight: 34)
            .animation(.easeInOut(duration: 0.2), value: phaseDescription)
    }

    private var phaseDescription: String {
        if engine.isCPUOpponent && !engine.isHumanTurn && !engine.isGameOver {
            return "CPU が考え中…"
        }
        switch engine.phase {
        case .placing:
            return "\(engine.currentPlayer.rawValue) の番：コマを置いてください"
        case .moving:
            return engine.selectedIndex != nil
                ? "\(engine.currentPlayer.rawValue) の番：移動先のマスを選んでください"
                : "\(engine.currentPlayer.rawValue) の番：動かすコマを選んでください"
        case .finished:
            return "ゲーム終了"
        }
    }
}

#Preview {
    NavigationStack {
        GameView(engine: GameEngine())
    }
}
