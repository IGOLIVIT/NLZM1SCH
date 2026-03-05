//
//  LearnLessonView.swift
//  NLZM1SCH
//

import SwiftUI

struct LearnLessonView: View {
    let lessonId: String
    @Binding var path: [Route]
    @ObservedObject var progress: ProgressStore

    private var lesson: LessonDefinition? {
        Lessons.all.first { $0.id == lessonId }
    }

    var body: some View {
        ZStack {
            AppBackgroundView(style: .default)
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingLarge) {
                    if let lesson = lesson {
                        Text(lesson.content)
                            .font(.body)
                            .foregroundColor(Color("TextPrimary"))
                            .fixedSize(horizontal: false, vertical: true)
                        PrimaryButton(title: "Mark complete") {
                            progress.completeLesson(id: lesson.id)
                            if !path.isEmpty { path = Array(path.dropLast()) }
                        }
                        SecondaryButton(title: "Back") {
                            if !path.isEmpty { path = Array(path.dropLast()) }
                        }
                    }
                    Spacer(minLength: 24)
                }
                .padding(Theme.spacingLarge)
            }
        }
        .navigationTitle(lesson?.title ?? "Lesson")
        .navigationBarTitleDisplayMode(.inline)
    }
}
