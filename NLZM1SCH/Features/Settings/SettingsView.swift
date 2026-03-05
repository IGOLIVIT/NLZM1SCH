//
//  SettingsView.swift
//  NLZM1SCH
//

import SwiftUI

struct SettingsView: View {
    @Binding var path: [Route]
    @ObservedObject var progress: ProgressStore
    @AppStorage("onboardingCompleted") private var onboardingCompleted: Bool = false
    @State private var showResetConfirmation: Bool = false

    var body: some View {
        ZStack {
            AppBackgroundView(style: .default)
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingLarge) {
                    Text("Stats")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    VStack(alignment: .leading, spacing: Theme.spacingSmall) {
                        statRow("Games played", "\(progress.gamesPlayed)")
                        statRow("Games won", "\(progress.gamesWon)")
                        statRow("Lessons completed", "\(progress.lessonsCompleted.count)")
                        statRow("Achievements", "\(progress.unlockedAchievementIds.count)")
                    }
                    .padding(Theme.spacingMedium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardBackground()
                    .padding(.horizontal)

                    PrimaryButton(title: "Reset progress") {
                        showResetConfirmation = true
                    }
                    .padding(.horizontal)
                    .padding(.top, Theme.spacingMedium)

                    Spacer(minLength: 24)
                }
                .padding(.vertical, Theme.spacingLarge)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                progress.resetProgress()
                onboardingCompleted = false
                path = []
            }
        } message: {
            Text("All progress and stats will be cleared. You will see onboarding again.")
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundColor(Color("TextSecondary"))
            Spacer()
            Text(value).foregroundColor(Color("TextPrimary")).fontWeight(.medium)
        }
    }
}
