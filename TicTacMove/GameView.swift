import SwiftUI
import UIKit

struct GameView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject private var progress = ProgressStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti = false

    var body: some View {
        GeometryReader { geometry in
            // Computed once from the screen's own (stable) size — not from
            // an inner GeometryReader competing with a sibling Spacer for
            // leftover height, which made the board visibly drift/bounce.
            let boardSide = min(geometry.size.width - 40, geometry.size.height - 260)

            ZStack {
                AmbientBackground()

                VStack(spacing: 24) {
                    topBar
                    header
                    BoardView(engine: engine, side: boardSide)
                    Spacer(minLength: 0)
                }
                .padding(.top, 8)
                .padding(.bottom, 24)

                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }

                if engine.isGameOver {
                    GameOverOverlay(winner: engine.winner) {
                        playAgain()
                    }
                    .transition(.opacity)
                }
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
            guard let winner else { return }
            progress.recordWin(for: winner)
            celebrateWin()
        }
        .onAppear {
            SoundPlayer.shared.startBGM()
            triggerAIIfNeeded()
        }
        .onDisappear {
            SoundPlayer.shared.stopBGM()
        }
    }

    private func playAgain() {
        withAnimation { showConfetti = false }
        AdManager.shared.showAd {
            engine.reset()
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
                    SkinsView()
                } label: {
                    Label("スキン", systemImage: "paintpalette")
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
        let tint = progress.currentSkin.color(for: player)
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
