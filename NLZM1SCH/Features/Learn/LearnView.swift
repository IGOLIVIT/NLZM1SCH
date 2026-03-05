//
//  LearnView.swift
//  NLZM1SCH
//

import SwiftUI

struct LearnView: View {
    @Binding var path: [Route]
    @ObservedObject var progress: ProgressStore

    var body: some View {
        ZStack {
            AppBackgroundView(style: .default)
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingLarge) {
                    ForEach(Lessons.all) { lesson in
                        CardView(action: { path = path + [.learnLesson(id: lesson.id)] }) {
                            HStack {
                                VStack(alignment: .leading, spacing: Theme.spacingSmall) {
                                    Text(lesson.title)
                                        .font(.headline)
                                        .foregroundColor(Color("TextPrimary"))
                                }
                                Spacer()
                                if progress.hasCompletedLesson(lesson.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("ElectricClover"))
                                }
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("TextSecondary"))
                            }
                        }
                        .padding(.horizontal)
                    }
                    Spacer(minLength: 24)
                }
                .padding(.vertical, Theme.spacingLarge)
            }
        }
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.inline)
    }
}
