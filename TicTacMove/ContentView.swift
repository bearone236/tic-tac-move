import SwiftUI

struct ContentView: View {
    @StateObject private var engine = GameEngine()

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
            .padding(.top, 24)
        }
        .alert(
            "ゲーム終了",
            isPresented: Binding(
                get: { engine.isGameOver },
                set: { _ in }
            )
        ) {
            Button("もう一度") {
                withAnimation { engine.reset() }
            }
        } message: {
            if let winner = engine.winner {
                Text("\(winner.rawValue) の勝ちです！")
            }
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
            Text("Tic Tac Move")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
                )

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
            withAnimation { engine.reset() }
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
    ContentView()
}
