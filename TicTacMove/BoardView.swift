import SwiftUI

struct BoardView: View {
    @ObservedObject var engine: GameEngine

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: GameEngine.boardSize
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<engine.board.count, id: \.self) { index in
                CellView(
                    player: engine.board[index],
                    isSelected: engine.selectedIndex == index,
                    isWinningCell: engine.winningLine?.contains(index) ?? false
                )
                .onTapGesture {
                    engine.tapCell(index)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct CellView: View {
    let player: Player?
    let isSelected: Bool
    let isWinningCell: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.yellow : Color.primary.opacity(0.15),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .overlay(
                Text(player?.rawValue ?? "")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(foregroundColor)
            )
    }

    private var backgroundColor: Color {
        isWinningCell ? Color.green.opacity(0.35) : Color(.secondarySystemBackground)
    }

    private var foregroundColor: Color {
        player == .x ? .blue : .red
    }
}

#Preview {
    BoardView(engine: GameEngine())
        .padding()
}
