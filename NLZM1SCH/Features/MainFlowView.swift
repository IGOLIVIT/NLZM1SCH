//
//  MainFlowView.swift
//  NLZM1SCH
//

import SwiftUI

struct MainFlowView: View {
    @StateObject private var progress = ProgressStore.shared
    @State private var path: [Route] = []

    var body: some View {
        NavigationView {
            HomeView(path: $path, progress: progress)
                .background(
                    Group {
                        if !path.isEmpty {
                            NavigationLink(
                                destination: NavChainView(path: $path, depth: 0, progress: progress),
                                isActive: Binding(
                                    get: { !path.isEmpty },
                                    set: { if !$0 { path = [] } }
                                )
                            ) { EmptyView() }
                        }
                    }
                )
        }
        .navigationViewStyle(.stack)
        .environmentObject(progress)
    }
}

private struct NavChainView: View {
    @Binding var path: [Route]
    let depth: Int
    @ObservedObject var progress: ProgressStore

    var body: some View {
        if depth < path.count {
            viewFor(path[depth])
                .background(
                    Group {
                        if depth + 1 < path.count {
                            NavigationLink(
                                destination: NavChainView(path: $path, depth: depth + 1, progress: progress),
                                isActive: Binding(
                                    get: { path.count > depth + 1 },
                                    set: { if !$0 { path = Array(path.prefix(depth + 1)) } }
                                )
                            ) { EmptyView() }
                        }
                    }
                )
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func viewFor(_ route: Route) -> some View {
        switch route {
        case .learn:
            LearnView(path: $path, progress: progress)
        case .learnLesson(let id):
            LearnLessonView(lessonId: id, path: $path, progress: progress)
        case .play(let hints):
            PlayCheckersView(hintsEnabled: hints, path: $path, progress: progress)
        case .rules:
            RulesView()
        case .settings:
            SettingsView(path: $path, progress: progress)
        case .onboarding:
            EmptyView()
        }
    }
}
