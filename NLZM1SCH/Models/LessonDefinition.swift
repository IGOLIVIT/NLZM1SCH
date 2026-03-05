//
//  LessonDefinition.swift
//  NLZM1SCH
//

import Foundation

struct LessonDefinition: Identifiable {
    let id: String
    let title: String
    let content: String
}

enum Lessons {
    static let all: [LessonDefinition] = [
        LessonDefinition(id: "basics", title: "How pieces move", content: "Pieces move diagonally forward, one square at a time, on dark squares only. Light pieces move upward (toward row 0), dark pieces move downward (toward row 7)."),
        LessonDefinition(id: "capture", title: "Capturing", content: "To capture, jump over an opponent's piece to an empty square. The captured piece is removed. If you can capture, you must. You can sometimes capture several pieces in one turn by making multiple jumps."),
        LessonDefinition(id: "king", title: "Kings", content: "When a piece reaches the far row (the first row on the opponent's side), it becomes a king. A king moves along the full diagonal in any direction (until blocked) and, when capturing, may land on any empty square behind the taken piece.")
    ]
}
