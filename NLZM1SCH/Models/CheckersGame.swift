//
//  CheckersGame.swift
//  NLZM1SCH
//

import Foundation
import Combine

struct CheckerPiece: Equatable {
    var isKing: Bool
    var isLight: Bool
}

struct BoardPosition: Hashable, Equatable {
    var row: Int
    var col: Int
}

struct CheckersMove: Equatable {
    var from: BoardPosition
    var to: BoardPosition
    var captured: [BoardPosition]
}

final class CheckersGame: ObservableObject {
    static let size = 8
    @Published private(set) var board: [[CheckerPiece?]]
    @Published private(set) var currentLightTurn: Bool = true
    @Published private(set) var gameOver: Bool = false
    @Published private(set) var winnerIsLight: Bool? = nil
    @Published var selectedPosition: BoardPosition?
    @Published var hintMoves: [CheckersMove] = []
    @Published var hintMessage: String? = nil
    var hintsEnabled: Bool = false

    init() {
        board = Self.initialBoard()
    }

    static func initialBoard() -> [[CheckerPiece?]] {
        var b = [[CheckerPiece?]](repeating: [CheckerPiece?](repeating: nil, count: size), count: size)
        for row in 0..<size {
            for col in 0..<size where (row + col) % 2 == 1 {
                if row < 3 { b[row][col] = CheckerPiece(isKing: false, isLight: false) }
                else if row > 4 { b[row][col] = CheckerPiece(isKing: false, isLight: true) }
            }
        }
        return b
    }

    func piece(at pos: BoardPosition) -> CheckerPiece? {
        guard pos.row >= 0, pos.row < Self.size, pos.col >= 0, pos.col < Self.size else { return nil }
        return board[pos.row][pos.col]
    }

    func setPiece(_ piece: CheckerPiece?, at pos: BoardPosition) {
        guard pos.row >= 0, pos.row < Self.size, pos.col >= 0, pos.col < Self.size else { return }
        board[pos.row][pos.col] = piece
    }

    func isDarkSquare(_ pos: BoardPosition) -> Bool {
        (pos.row + pos.col) % 2 == 1
    }

    func validMoves(from pos: BoardPosition) -> [CheckersMove] {
        guard let p = piece(at: pos), p.isLight == currentLightTurn else { return [] }
        let captures = allCaptures(from: pos)
        let anyCaptureExists = (0..<Self.size).contains { r in
            (0..<Self.size).contains { c in
                !allCaptures(from: BoardPosition(row: r, col: c)).isEmpty
                && piece(at: BoardPosition(row: r, col: c))?.isLight == currentLightTurn
            }
        }
        if anyCaptureExists { return captures }
        return simpleMoves(from: pos)
    }

    private func simpleMoves(from pos: BoardPosition) -> [CheckersMove] {
        guard let p = piece(at: pos) else { return [] }
        if p.isKing {
            return kingSimpleMoves(from: pos)
        }
        let dirs: [(Int, Int)] = p.isLight ? [(-1,-1),(-1,1)] : [(1,-1),(1,1)]
        var moves: [CheckersMove] = []
        for (dr, dc) in dirs {
            let to = BoardPosition(row: pos.row + dr, col: pos.col + dc)
            if piece(at: to) == nil && to.row >= 0 && to.row < Self.size && to.col >= 0 && to.col < Self.size && isDarkSquare(to) {
                moves.append(CheckersMove(from: pos, to: to, captured: []))
            }
        }
        return moves
    }

    /// King slides along the full diagonal in any direction until blocked or edge.
    private func kingSimpleMoves(from pos: BoardPosition) -> [CheckersMove] {
        var moves: [CheckersMove] = []
        for (dr, dc) in [(-1,-1),(-1,1),(1,-1),(1,1)] {
            var r = pos.row + dr, c = pos.col + dc
            while r >= 0, r < Self.size, c >= 0, c < Self.size, isDarkSquare(BoardPosition(row: r, col: c)) {
                let to = BoardPosition(row: r, col: c)
                if piece(at: to) != nil { break }
                moves.append(CheckersMove(from: pos, to: to, captured: []))
                r += dr
                c += dc
            }
        }
        return moves
    }

    /// All single-step captures from pos (no recursion). King can land on any empty square behind the jumped piece.
    private func singleCaptures(from pos: BoardPosition, board: [[CheckerPiece?]]) -> [(to: BoardPosition, mid: BoardPosition)] {
        guard let p = pieceAt(pos, on: board) else { return [] }
        if p.isKing {
            return kingSingleCaptures(from: pos, board: board)
        }
        var result: [(BoardPosition, BoardPosition)] = []
        let dirs: [(Int, Int)] = p.isLight ? [(-1,-1),(-1,1)] : [(1,-1),(1,1)]
        for (dr, dc) in dirs {
            let mid = BoardPosition(row: pos.row + dr, col: pos.col + dc)
            let to = BoardPosition(row: pos.row + 2*dr, col: pos.col + 2*dc)
            guard to.row >= 0, to.row < Self.size, to.col >= 0, to.col < Self.size, isDarkSquare(to) else { continue }
            guard let midPiece = pieceAt(mid, on: board), midPiece.isLight != p.isLight else { continue }
            if pieceAt(to, on: board) == nil {
                result.append((to, mid))
            }
        }
        return result
    }

    /// King: jump over first enemy on diagonal, land on any empty square behind it.
    private func kingSingleCaptures(from pos: BoardPosition, board: [[CheckerPiece?]]) -> [(to: BoardPosition, mid: BoardPosition)] {
        var result: [(BoardPosition, BoardPosition)] = []
        for (dr, dc) in [(-1,-1),(-1,1),(1,-1),(1,1)] {
            var r = pos.row + dr, c = pos.col + dc
            while r >= 0, r < Self.size, c >= 0, c < Self.size, isDarkSquare(BoardPosition(row: r, col: c)) {
                let mid = BoardPosition(row: r, col: c)
                if let midPiece = pieceAt(mid, on: board) {
                    if midPiece.isLight != pieceAt(pos, on: board)!.isLight {
                        var r2 = r + dr, c2 = c + dc
                        while r2 >= 0, r2 < Self.size, c2 >= 0, c2 < Self.size, isDarkSquare(BoardPosition(row: r2, col: c2)) {
                            let to = BoardPosition(row: r2, col: c2)
                            if pieceAt(to, on: board) != nil { break }
                            result.append((to, mid))
                            r2 += dr
                            c2 += dc
                        }
                    }
                    break
                }
                r += dr
                c += dc
            }
        }
        return result
    }

    private func pieceAt(_ pos: BoardPosition, on board: [[CheckerPiece?]]) -> CheckerPiece? {
        guard pos.row >= 0, pos.row < Self.size, pos.col >= 0, pos.col < Self.size else { return nil }
        return board[pos.row][pos.col]
    }

    /// Build all capture moves from pos (including multi-jumps). Uses a copy of the board.
    private func allCapturesFromBoard(_ board: [[CheckerPiece?]], from pos: BoardPosition, piece: CheckerPiece, startPos: BoardPosition, capturedSoFar: [BoardPosition]) -> [CheckersMove] {
        let singles = singleCaptures(from: pos, board: board)
        var moves: [CheckersMove] = []
        for (to, mid) in singles {
            var newBoard = board
            newBoard[pos.row][pos.col] = nil
            newBoard[mid.row][mid.col] = nil
            var newPiece = piece
            if (piece.isLight && to.row == 0) || (!piece.isLight && to.row == Self.size - 1) {
                newPiece.isKing = true
            }
            newBoard[to.row][to.col] = newPiece
            let continued = allCapturesFromBoard(newBoard, from: to, piece: newPiece, startPos: startPos, capturedSoFar: capturedSoFar + [mid])
            if continued.isEmpty {
                moves.append(CheckersMove(from: startPos, to: to, captured: capturedSoFar + [mid]))
            } else {
                moves.append(contentsOf: continued)
            }
        }
        return moves
    }

    /// Returns only maximal captures from pos (if you can take 2, don't return the move that takes 1).
    private func allCaptures(from pos: BoardPosition) -> [CheckersMove] {
        guard let p = piece(at: pos), p.isLight == currentLightTurn else { return [] }
        let all = allCapturesFromBoard(board, from: pos, piece: p, startPos: pos, capturedSoFar: [])
        guard !all.isEmpty else { return [] }
        let maxCount = all.map { $0.captured.count }.max() ?? 0
        return all.filter { $0.captured.count == maxCount }
    }

    func applyMove(_ move: CheckersMove) {
        guard let p = piece(at: move.from) else { return }
        setPiece(nil, at: move.from)
        for cap in move.captured { setPiece(nil, at: cap) }
        var newPiece = p
        if (p.isLight && move.to.row == 0) || (!p.isLight && move.to.row == Self.size - 1) {
            newPiece.isKing = true
        }
        setPiece(newPiece, at: move.to)
        selectedPosition = nil
        hintMoves = []
        currentLightTurn.toggle()
        checkGameOver()
    }

    func allMovesForCurrentSide() -> [CheckersMove] {
        var moves: [CheckersMove] = []
        for r in 0..<Self.size {
            for c in 0..<Self.size {
                moves.append(contentsOf: validMoves(from: BoardPosition(row: r, col: c)))
            }
        }
        return moves
    }

    func makeAIMove() {
        let moves = allMovesForCurrentSide()
        guard let move = moves.randomElement() else { return }
        applyMove(move)
    }

    private func checkGameOver() {
        var lightCount = 0, darkCount = 0
        for row in board {
            for cell in row {
                if let p = cell {
                    if p.isLight { lightCount += 1 } else { darkCount += 1 }
                }
            }
        }
        if darkCount == 0 { gameOver = true; winnerIsLight = true }
        else if lightCount == 0 { gameOver = true; winnerIsLight = false }
    }

    /// Positions of current side's pieces that have at least one valid move (for hints).
    func piecePositionsWithMoves() -> [BoardPosition] {
        var result: [BoardPosition] = []
        for r in 0..<Self.size {
            for c in 0..<Self.size {
                let pos = BoardPosition(row: r, col: c)
                if piece(at: pos) != nil, piece(at: pos)?.isLight == currentLightTurn, !validMoves(from: pos).isEmpty {
                    result.append(pos)
                }
            }
        }
        return result
    }

    func tap(at pos: BoardPosition) {
        if gameOver { return }
        hintMessage = nil
        if let sel = selectedPosition {
            let moves = validMoves(from: sel)
            if let move = moves.first(where: { $0.to == pos }) {
                applyMove(move)
                return
            }
        }
        if let p = piece(at: pos), p.isLight == currentLightTurn {
            let moves = validMoves(from: pos)
            if moves.isEmpty {
                selectedPosition = nil
                hintMoves = []
                if hintsEnabled {
                    hintMessage = "This piece cannot move. You must make a capture with another piece."
                }
            } else {
                selectedPosition = pos
                hintMoves = moves
            }
        } else {
            selectedPosition = nil
            hintMoves = []
        }
    }

    func suggestedMove() -> CheckersMove? {
        var allMoves: [CheckersMove] = []
        for r in 0..<Self.size {
            for c in 0..<Self.size {
                let pos = BoardPosition(row: r, col: c)
                allMoves.append(contentsOf: validMoves(from: pos))
            }
        }
        return allMoves.randomElement()
    }

    func reset() {
        board = Self.initialBoard()
        currentLightTurn = true
        gameOver = false
        winnerIsLight = nil
        selectedPosition = nil
        hintMoves = []
        hintMessage = nil
    }
}
