//
//  ProgressStore.swift
//  NLZM1SCH
//

import Foundation
import SwiftUI
import Combine

final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published private(set) var gamesPlayed: Int
    @Published private(set) var gamesWon: Int
    @Published private(set) var lessonsCompleted: Set<String>
    @Published private(set) var unlockedAchievementIds: Set<String>

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    struct Persisted: Codable {
        var gamesPlayed: Int
        var gamesWon: Int
        var lessonsCompleted: [String]
        var unlockedAchievementIds: [String]
    }

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = docs.appendingPathComponent("progress.json")
        gamesPlayed = 0
        gamesWon = 0
        lessonsCompleted = []
        unlockedAchievementIds = []
        load()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let p = try? decoder.decode(Persisted.self, from: data) else { return }
        gamesPlayed = p.gamesPlayed
        gamesWon = p.gamesWon
        lessonsCompleted = Set(p.lessonsCompleted)
        unlockedAchievementIds = Set(p.unlockedAchievementIds)
    }

    private func save() {
        let p = Persisted(
            gamesPlayed: gamesPlayed,
            gamesWon: gamesWon,
            lessonsCompleted: Array(lessonsCompleted),
            unlockedAchievementIds: Array(unlockedAchievementIds)
        )
        guard let data = try? encoder.encode(p) else { return }
        try? data.write(to: fileURL)
    }

    func reportGameFinished(won: Bool) {
        gamesPlayed += 1
        if won { gamesWon += 1 }
        if gamesWon >= 1 { unlockedAchievementIds.insert("first_win") }
        if gamesPlayed >= 10 { unlockedAchievementIds.insert("ten_games") }
        save()
    }

    func completeLesson(id: String) {
        lessonsCompleted.insert(id)
        if lessonsCompleted.count >= 3 { unlockedAchievementIds.insert("lessons_done") }
        save()
    }

    func hasCompletedLesson(_ id: String) -> Bool {
        lessonsCompleted.contains(id)
    }

    func resetProgress() {
        gamesPlayed = 0
        gamesWon = 0
        lessonsCompleted = []
        unlockedAchievementIds = []
        save()
    }
}
