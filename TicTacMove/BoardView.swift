import SwiftUI
import UIKit

struct BoardView: View {
    @ObservedObject var engine: GameEngine

    /// Fixed content size (width == height), supplied by the caller from a
    /// stable measurement — see GameView. Deliberately NOT computed via an
    /// internal GeometryReader here: a GeometryReader competing with a
    /// sibling Spacer for leftover VStack height is unstable and made the
    /// board visibly drift/bounce during animations.
    let side: CGFloat

    private let spacing: CGFloat = 12

    private var cellSize: CGFloat {
        (side - spacing * CGFloat(GameEngine.boardSize - 1)) / CGFloat(GameEngine.boardSize)
    }

    var body: some View {
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
                .position(center(of: piece.index))
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: piece.index)
                .allowsHitTesting(false)
            }
        }
        .frame(width: side, height: side)
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

    private func center(of index: Int) -> CGPoint {
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

    @ObservedObject private var progress = ProgressStore.shared

    var body: some View {
        let skin = progress.currentSkin
        let color = skin.color(for: player)
        PieceGlyph(player: player, style: skin.style, color: color)
            .shadow(color: color.opacity(isWinningCell ? 1 : 0.7), radius: isWinningCell ? 14 : 8)
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

#Preview {
    BoardView(engine: GameEngine(), side: 320)
        .padding()
        .background(Theme.background)
}
