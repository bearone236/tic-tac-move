import Foundation

enum Player: String {
    case x = "X"
    case o = "O"

    var opponent: Player { self == .x ? .o : .x }

    var displayColorName: String {
        self == .x ? "blue" : "red"
    }
}

enum GamePhase {
    case placing
    case moving
    case finished
}

/// Classic 3x3 tic-tac-toe, but once both players have placed all 3 of
/// their pieces, further turns move an existing piece to an adjacent
/// empty cell instead of placing a new one.
final class GameEngine: ObservableObject {
    static let boardSize = 3
    static let piecesPerPlayer = 3

    private static let winningLines: [[Int]] = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6],
    ]

    @Published private(set) var board: [Player?]
    @Published private(set) var currentPlayer: Player = .x
    @Published private(set) var phase: GamePhase = .placing
    @Published private(set) var winner: Player?
    @Published private(set) var winningLine: [Int]?
    @Published private(set) var selectedIndex: Int?
    @Published private(set) var scoreX = 0
    @Published private(set) var scoreO = 0

    private var placedCount: [Player: Int] = [.x: 0, .o: 0]

    init() {
        board = Array(repeating: nil, count: Self.boardSize * Self.boardSize)
    }

    var isGameOver: Bool { phase == .finished }

    func tapCell(_ index: Int) {
        switch phase {
        case .placing:
            placePiece(at: index)
        case .moving:
            handleMoveTap(at: index)
        case .finished:
            break
        }
    }

    func reset() {
        board = Array(repeating: nil, count: Self.boardSize * Self.boardSize)
        currentPlayer = .x
        phase = .placing
        winner = nil
        winningLine = nil
        selectedIndex = nil
        placedCount = [.x: 0, .o: 0]
    }

    func resetScores() {
        scoreX = 0
        scoreO = 0
    }

    private func placePiece(at index: Int) {
        guard board[index] == nil else { return }

        board[index] = currentPlayer
        placedCount[currentPlayer, default: 0] += 1

        if checkWin(for: currentPlayer) {
            finishGame(winner: currentPlayer)
            return
        }

        if placedCount[.x] == Self.piecesPerPlayer && placedCount[.o] == Self.piecesPerPlayer {
            phase = .moving
        }

        currentPlayer = currentPlayer.opponent
    }

    private func handleMoveTap(at index: Int) {
        guard let selected = selectedIndex else {
            if board[index] == currentPlayer {
                selectedIndex = index
            }
            return
        }

        if selected == index {
            selectedIndex = nil
            return
        }

        if board[index] == currentPlayer {
            selectedIndex = index
            return
        }

        guard board[index] == nil, adjacentIndices(of: selected).contains(index) else {
            return
        }

        board[index] = currentPlayer
        board[selected] = nil
        selectedIndex = nil

        if checkWin(for: currentPlayer) {
            finishGame(winner: currentPlayer)
            return
        }

        if !hasLegalMove(for: currentPlayer.opponent) {
            finishGame(winner: currentPlayer)
            return
        }

        currentPlayer = currentPlayer.opponent
    }

    private func adjacentIndices(of index: Int) -> [Int] {
        let row = index / Self.boardSize
        let col = index % Self.boardSize
        var result: [Int] = []
        for dr in -1...1 {
            for dc in -1...1 where dr != 0 || dc != 0 {
                let r = row + dr
                let c = col + dc
                if r >= 0, r < Self.boardSize, c >= 0, c < Self.boardSize {
                    result.append(r * Self.boardSize + c)
                }
            }
        }
        return result
    }

    private func hasLegalMove(for player: Player) -> Bool {
        for (index, value) in board.enumerated() where value == player {
            if adjacentIndices(of: index).contains(where: { board[$0] == nil }) {
                return true
            }
        }
        return false
    }

    private func checkWin(for player: Player) -> Bool {
        for line in Self.winningLines where line.allSatisfy({ board[$0] == player }) {
            winningLine = line
            return true
        }
        return false
    }

    private func finishGame(winner: Player) {
        self.winner = winner
        phase = .finished
        if winner == .x {
            scoreX += 1
        } else {
            scoreO += 1
        }
    }
}
