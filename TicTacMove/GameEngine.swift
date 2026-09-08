import Foundation

/// A single placed piece with a stable identity, so the board view can
/// animate it sliding between cells instead of cross-fading.
struct BoardPiece: Identifiable {
    let id: UUID
    let player: Player
    let index: Int
}

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
    private var pieceIDs: [UUID?]
    @Published private(set) var currentPlayer: Player = .x
    @Published private(set) var phase: GamePhase = .placing
    @Published private(set) var winner: Player?
    @Published private(set) var winningLine: [Int]?
    @Published private(set) var selectedIndex: Int?
    @Published private(set) var scoreX = 0
    @Published private(set) var scoreO = 0
    @Published var isCPUOpponent = true

    private var placedCount: [Player: Int] = [.x: 0, .o: 0]

    init() {
        board = Array(repeating: nil, count: Self.boardSize * Self.boardSize)
        pieceIDs = Array(repeating: nil, count: Self.boardSize * Self.boardSize)
    }

    var isGameOver: Bool { phase == .finished }

    /// The placed pieces, each with a stable id that carries over when a
    /// piece moves so the board view can animate its position sliding.
    var pieces: [BoardPiece] {
        (0..<board.count).compactMap { index in
            guard let player = board[index], let id = pieceIDs[index] else { return nil }
            return BoardPiece(id: id, player: player, index: index)
        }
    }

    /// CPU always plays O; the human plays X and moves first.
    var isHumanTurn: Bool { !(isCPUOpponent && currentPlayer == .o) }

    /// Empty cells the currently-selected piece may legally move to, for highlighting.
    var validDestinations: Set<Int> {
        guard phase == .moving, let selected = selectedIndex else { return [] }
        return Set(adjacentIndices(of: selected).filter { board[$0] == nil })
    }

    /// Entry point for human taps on the board. Refuses to act when it's the
    /// CPU's turn, so the human can never move the CPU's pieces even if a
    /// stale UI briefly lets a tap through.
    func humanTapCell(_ index: Int) {
        guard isHumanTurn else { return }
        processTap(index)
    }

    private func processTap(_ index: Int) {
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
        pieceIDs = Array(repeating: nil, count: Self.boardSize * Self.boardSize)
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
        pieceIDs[index] = UUID()
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
        pieceIDs[index] = pieceIDs[selected]
        pieceIDs[selected] = nil
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

    // MARK: - CPU opponent

    private enum Action {
        case place(Int)
        case move(Int, Int)
    }

    /// Picks and applies a move for the current player via the same `tapCell`
    /// path a human uses, so scoring/win-detection stay in one place.
    func performAIMove() {
        guard !isGameOver else { return }
        let player = currentPlayer
        let candidates = actions(on: board, phase: phase, for: player)
        guard !candidates.isEmpty else { return }

        if let winningMove = candidates.first(where: { Self.winner(on: apply($0, to: board, by: player)) == player }) {
            perform(winningMove)
            return
        }

        let opponent = player.opponent
        let safeMoves = candidates.filter { action in
            let nextBoard = apply(action, to: board, by: player)
            let nextPlacedCount = updatedPlacedCount(after: action, player: player)
            let nextPhase = updatedPhase(after: nextPlacedCount)
            let opponentReplies = actions(on: nextBoard, phase: nextPhase, for: opponent)
            return !opponentReplies.contains { reply in
                Self.winner(on: apply(reply, to: nextBoard, by: opponent)) == opponent
            }
        }

        let pool = safeMoves.isEmpty ? candidates : safeMoves
        if let chosen = pool.randomElement() {
            perform(chosen)
        }
    }

    private func perform(_ action: Action) {
        switch action {
        case .place(let index):
            processTap(index)
        case .move(let from, let to):
            processTap(from)
            processTap(to)
        }
    }

    private func actions(on board: [Player?], phase: GamePhase, for player: Player) -> [Action] {
        switch phase {
        case .placing:
            return board.indices.filter { board[$0] == nil }.map { .place($0) }
        case .moving:
            var result: [Action] = []
            for (index, value) in board.enumerated() where value == player {
                for adjacent in adjacentIndices(of: index) where board[adjacent] == nil {
                    result.append(.move(index, adjacent))
                }
            }
            return result
        case .finished:
            return []
        }
    }

    private func apply(_ action: Action, to board: [Player?], by player: Player) -> [Player?] {
        var result = board
        switch action {
        case .place(let index):
            result[index] = player
        case .move(let from, let to):
            result[to] = player
            result[from] = nil
        }
        return result
    }

    private func updatedPlacedCount(after action: Action, player: Player) -> [Player: Int] {
        guard case .place = action else { return placedCount }
        var copy = placedCount
        copy[player, default: 0] += 1
        return copy
    }

    private func updatedPhase(after placedCount: [Player: Int]) -> GamePhase {
        guard phase == .placing else { return phase }
        return placedCount[.x] == Self.piecesPerPlayer && placedCount[.o] == Self.piecesPerPlayer
            ? .moving : .placing
    }

    private static func winner(on board: [Player?]) -> Player? {
        for line in winningLines {
            if let first = board[line[0]], line.allSatisfy({ board[$0] == first }) {
                return first
            }
        }
        return nil
    }
}
