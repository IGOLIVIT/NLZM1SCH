//
//  TodaysFocus.swift
//  NLZM1SCH
//

import Foundation

enum TodaysFocus {
    private static let tips: [String] = [
        "Light pieces move only upward; dark pieces move only downward.",
        "A piece becomes a king when it reaches the opposite end of the board.",
        "Kings can move and capture in all four diagonal directions.",
        "If a capture is possible, you must take it.",
        "Plan several moves ahead to set up multiple captures.",
        "Control the center of the board when you can.",
        "Use the edges to protect your pieces from being captured."
    ]

    static var current: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return tips[day % tips.count]
    }
}
