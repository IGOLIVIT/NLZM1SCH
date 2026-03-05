//
//  RulesEntry.swift
//  NLZM1SCH
//

import Foundation

struct RulesEntry: Identifiable {
    let id: String
    let title: String
    let body: String
}

enum RulesGlossary {
    static let entries: [RulesEntry] = [
        RulesEntry(id: "board", title: "The board", body: "Checkers is played on an 8×8 board. Only the dark squares are used. Each side has 12 pieces at the start."),
        RulesEntry(id: "move", title: "Moving", body: "Pieces move one square diagonally forward onto a dark square. A king moves along the full diagonal in any direction (like a bishop), until blocked or the edge of the board."),
        RulesEntry(id: "capture", title: "Capturing", body: "Jump over an opponent's piece to an empty square. The piece you jump is removed. If from the new square you can capture again, you must continue in the same turn (double or triple capture). Captures are mandatory when possible; you must take the maximum number of pieces available. A king can land on any empty square behind the captured piece along the same diagonal."),
        RulesEntry(id: "king", title: "Crowning", body: "When a piece reaches the opposite back row, it is crowned a king. A king moves along the full diagonal in any direction and, when capturing, may land on any empty square behind the taken piece.")
    ]
}
