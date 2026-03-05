//
//  PlayCheckersView.swift
//  NLZM1SCH
//

import SwiftUI

struct PlayCheckersView: View {
    let hintsEnabled: Bool
    @Binding var path: [Route]
    @ObservedObject var progress: ProgressStore
    @StateObject private var game = CheckersGame()
    @State private var showGameOver = false
    @State private var aiThinking = false

    var body: some View {
        ZStack {
            AppBackgroundView(style: .game)
            VStack(spacing: Theme.spacingMedium) {
                if game.gameOver, let winner = game.winnerIsLight {
                    Text(winner ? "You win!" : "Game over")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(winner ? Color("ElectricClover") : Color("WarmGold"))
                } else {
                    Text(game.currentLightTurn ? "Your turn" : "Opponent's turn")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                }
                if game.hintsEnabled, let msg = game.hintMessage {
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(Color("WarmGold"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                CheckersBoardView(game: game)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal)
                HStack(spacing: Theme.spacingLarge) {
                    PrimaryButton(title: "New game") { newGame() }
                    SecondaryButton(title: "Back") { path = [] }
                }
                .padding(.horizontal)
                Spacer(minLength: 24)
            }
            .padding(.vertical, Theme.spacingMedium)
        }
        .navigationTitle(hintsEnabled ? "Play (hints)" : "Play")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            game.hintsEnabled = hintsEnabled
        }
        .onChange(of: game.currentLightTurn) { isLight in
            if !isLight && !game.gameOver {
                aiThinking = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    game.makeAIMove()
                    aiThinking = false
                }
            }
        }
        .onChange(of: game.gameOver) { over in
            if over {
                progress.reportGameFinished(won: game.winnerIsLight == true)
            }
        }
    }

    private func newGame() {
        game.reset()
        game.hintsEnabled = hintsEnabled
    }
}

struct CheckersBoardView: View {
    @ObservedObject var game: CheckersGame

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let cellSize = side / CGFloat(CheckersGame.size)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("DeepForest"))
                    .padding(4)
                VStack(spacing: 0) {
                    ForEach(0..<CheckersGame.size, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<CheckersGame.size, id: \.self) { col in
                                let pos = BoardPosition(row: row, col: col)
                                cellView(pos: pos, cellSize: cellSize)
                            }
                        }
                    }
                }
                .padding(8)
            }
            .frame(width: side + 16, height: side + 16)
        }
    }

    private func cellView(pos: BoardPosition, cellSize: CGFloat) -> some View {
        let isDark = game.isDarkSquare(pos)
        let isSelected = game.selectedPosition == pos
        let isDestination = game.hintMoves.contains { $0.to == pos }
        let canMove = game.hintsEnabled && game.currentLightTurn && game.piecePositionsWithMoves().contains(pos)
        return Button {
            game.tap(at: pos)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(isDark ? Color("SurfaceCard") : Color("BoardLight"))
                if isSelected {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color("ElectricClover"), lineWidth: 3)
                }
                if isDestination {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("WarmGold").opacity(0.5))
                    Circle()
                        .stroke(Color("WarmGold"), lineWidth: 2.5)
                        .frame(width: cellSize * 0.35, height: cellSize * 0.35)
                }
                if let piece = game.piece(at: pos) {
                    pieceView(piece: piece, size: cellSize * 0.7, showCanMoveRing: canMove && !isSelected)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: cellSize, height: cellSize)
    }

    private func pieceView(piece: CheckerPiece, size: CGFloat, showCanMoveRing: Bool = false) -> some View {
        ZStack {
            if showCanMoveRing {
                Circle()
                    .stroke(Color("ElectricClover"), lineWidth: 2)
                    .frame(width: size + 6, height: size + 6)
            }
            Circle()
                .fill(piece.isLight ? Color("BoardLight") : Color("DeepForest"))
                .overlay(Circle().stroke(piece.isLight ? Color("WarmGold") : Color("ElectricClover"), lineWidth: 2))
                .frame(width: size, height: size)
            if piece.isKing {
                Circle()
                    .stroke(piece.isLight ? Color("WarmGold") : Color("ElectricClover"), lineWidth: 3)
                    .frame(width: size * 0.5, height: size * 0.5)
            }
        }
    }
}
