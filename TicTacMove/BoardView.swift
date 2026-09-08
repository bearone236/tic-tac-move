import SwiftUI
import UIKit

struct BoardView: View {
    @ObservedObject var engine: GameEngine

    private let spacing: CGFloat = 12

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let cellSize = (side - spacing * CGFloat(GameEngine.boardSize - 1)) / CGFloat(GameEngine.boardSize)

            VStack(spacing: spacing) {
                ForEach(0..<GameEngine.boardSize, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<GameEngine.boardSize, id: \.self) { col in
                            let index = row * GameEngine.boardSize + col
                            CellView(
                                player: engine.board[index],
                                isSelected: engine.selectedIndex == index,
                                isWinningCell: engine.winningLine?.contains(index) ?? false
                            )
                            .frame(width: cellSize, height: cellSize)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    engine.tapCell(index)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
        )
    }
}

private struct CellView: View {
    let player: Player?
    let isSelected: Bool
    let isWinningCell: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(backgroundGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor, lineWidth: isSelected ? 3 : 1)
            )
            .overlay(mark)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(color: isWinningCell ? Color.green.opacity(0.5) : .clear, radius: 10)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            .animation(.easeInOut(duration: 0.3), value: isWinningCell)
    }

    @ViewBuilder
    private var mark: some View {
        if let player {
            Text(player.rawValue)
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(foregroundColor)
                .transition(.scale.combined(with: .opacity))
                .id(player.rawValue + String(isWinningCell))
        }
    }

    private var backgroundGradient: LinearGradient {
        if isWinningCell {
            return LinearGradient(
                colors: [Color.green.opacity(0.45), Color.green.opacity(0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color(.tertiarySystemGroupedBackground), Color(.tertiarySystemGroupedBackground)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private var borderColor: Color {
        isSelected ? Color.yellow : Color.primary.opacity(0.12)
    }

    private var foregroundColor: Color {
        player == .x ? .blue : .red
    }
}

#Preview {
    BoardView(engine: GameEngine())
        .padding()
}
