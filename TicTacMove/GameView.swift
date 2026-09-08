import SwiftUI
import UIKit

struct GameView: View {
    @ObservedObject var engine: GameEngine
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 28) {
                header
                BoardView(engine: engine)
                    .padding(.horizontal, 20)
                Spacer(minLength: 0)
                resetButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
            .padding(.top, 12)

            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .navigationTitle("Tic Tac Move")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onChange(of: engine.winner) { winner in
            guard winner != nil else { return }
            celebrateWin()
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

    private func celebrateWin() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation { showConfetti = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { showConfetti = false }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.indigo.opacity(0.18), Color.purple.opacity(0.10), Color(.systemGroupedBackground)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
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
        let tint: Color = player == .x ? .blue : .red
        return HStack(spacing: 8) {
            Text(player.rawValue)
                .font(.headline.bold())
            Text("\(player == .x ? engine.scoreX : engine.scoreO)")
                .font(.headline.monospacedDigit())
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(tint.opacity(0.15))
        )
    }

    private var statusBadge: some View {
        Text(phaseDescription)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color(.secondarySystemGroupedBackground)))
            .frame(minHeight: 34)
            .animation(.easeInOut(duration: 0.2), value: phaseDescription)
    }

    private var phaseDescription: String {
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

    private var resetButton: some View {
        Button {
            withAnimation {
                showConfetti = false
                engine.reset()
            }
        } label: {
            Label("リセット", systemImage: "arrow.counterclockwise")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(.indigo)
    }
}

#Preview {
    NavigationStack {
        GameView(engine: GameEngine())
    }
}
