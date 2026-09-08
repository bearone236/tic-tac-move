import SwiftUI

struct ContentView: View {
    @StateObject private var engine = GameEngine()

    var body: some View {
        VStack(spacing: 24) {
            header
            BoardView(engine: engine)
                .padding(.horizontal)
            Spacer()
            resetButton
        }
        .padding()
        .alert(
            "ゲーム終了",
            isPresented: Binding(
                get: { engine.isGameOver },
                set: { _ in }
            )
        ) {
            Button("もう一度") {
                engine.reset()
            }
        } message: {
            if let winner = engine.winner {
                Text("\(winner.rawValue) の勝ちです！")
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Tic Tac Move")
                .font(.largeTitle.bold())

            HStack(spacing: 32) {
                scoreLabel(for: .x)
                scoreLabel(for: .o)
            }

            Text(phaseDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(height: 20)
        }
    }

    private func scoreLabel(for player: Player) -> some View {
        VStack {
            Text(player.rawValue)
                .font(.headline)
                .foregroundStyle(player == .x ? .blue : .red)
            Text("\(player == .x ? engine.scoreX : engine.scoreO)")
                .font(.title2.monospacedDigit())
        }
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
            return ""
        }
    }

    private var resetButton: some View {
        Button(role: .destructive) {
            engine.reset()
        } label: {
            Text("リセット")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}

#Preview {
    ContentView()
}
