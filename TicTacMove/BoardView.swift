import SwiftUI
import UIKit

struct BoardView: View {
    @ObservedObject var engine: GameEngine

    private let spacing: CGFloat = 12

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let cellSize = (side - spacing * CGFloat(GameEngine.boardSize - 1)) / CGFloat(GameEngine.boardSize)

            ZStack {
                VStack(spacing: spacing) {
                    ForEach(0..<GameEngine.boardSize, id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<GameEngine.boardSize, id: \.self) { col in
                                let index = row * GameEngine.boardSize + col
                                Button {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        engine.humanTapCell(index)
                                    }
                                } label: {
                                    CellBackground(
                                        isSelected: engine.selectedIndex == index,
                                        isValidDestination: engine.validDestinations.contains(index),
                                        isWinningCell: engine.winningLine?.contains(index) ?? false
                                    )
                                    .frame(width: cellSize, height: cellSize)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .disabled(!engine.isHumanTurn)
                            }
                        }
                    }
                }

                ForEach(engine.pieces) { piece in
                    PieceMarkView(
                        player: piece.player,
                        isSelected: engine.selectedIndex == piece.index,
                        isWinningCell: engine.winningLine?.contains(piece.index) ?? false
                    )
                    .frame(width: cellSize, height: cellSize)
                    .position(center(of: piece.index, cellSize: cellSize))
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: piece.index)
                    .allowsHitTesting(false)
                }
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Theme.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Theme.cardStroke, lineWidth: 1)
                )
        )
    }

    private func center(of index: Int, cellSize: CGFloat) -> CGPoint {
        let row = index / GameEngine.boardSize
        let col = index % GameEngine.boardSize
        let x = CGFloat(col) * (cellSize + spacing) + cellSize / 2
        let y = CGFloat(row) * (cellSize + spacing) + cellSize / 2
        return CGPoint(x: x, y: y)
    }
}

private struct CellBackground: View {
    let isSelected: Bool
    let isValidDestination: Bool
    let isWinningCell: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(isWinningCell ? 0.16 : 0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor, lineWidth: isSelected || isValidDestination ? 2.5 : 1)
            )
            .overlay(destinationDot)
            .shadow(color: glowColor, radius: isWinningCell ? 12 : 0)
            .animation(.easeInOut(duration: 0.3), value: isWinningCell)
            .animation(.easeInOut(duration: 0.25), value: isValidDestination)
    }

    @ViewBuilder
    private var destinationDot: some View {
        if isValidDestination {
            Circle()
                .fill(Theme.accent.opacity(0.8))
                .frame(width: 14, height: 14)
                .shadow(color: Theme.accent, radius: 6)
        }
    }

    private var borderColor: Color {
        if isWinningCell { return Theme.accent }
        if isValidDestination { return Theme.accent.opacity(0.7) }
        return Color.white.opacity(0.12)
    }

    private var glowColor: Color {
        isWinningCell ? Theme.accent.opacity(0.6) : .clear
    }
}

private struct PieceMarkView: View {
    let player: Player
    let isSelected: Bool
    let isWinningCell: Bool

    var body: some View {
        Text(player.rawValue)
            .font(.system(size: 44, weight: .heavy, design: .rounded))
            .foregroundStyle(Theme.markColor(for: player))
            .shadow(color: Theme.markColor(for: player).opacity(isWinningCell ? 1 : 0.7), radius: isWinningCell ? 14 : 8)
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

#Preview {
    BoardView(engine: GameEngine())
        .padding()
        .background(Theme.background)
}
