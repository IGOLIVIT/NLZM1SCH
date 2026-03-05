//
//  OnboardingView.swift
//  NLZM1SCH
//

import SwiftUI

struct OnboardingView: View {
    @Binding var completed: Bool
    @State private var page = 0

    private let pages: [(title: String, subtitle: String)] = [
        ("Learn the rules", "Study how pieces move, capture, and become kings."),
        ("Practice with hints", "Play with suggested moves to improve your play."),
        ("Play on your own", "Turn off hints and test your skills.")
    ]

    var body: some View {
        ZStack {
            AppBackgroundView(style: .default)
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(0..<3, id: \.self) { i in
                        OnboardingPageView(title: pages[i].title, subtitle: pages[i].subtitle, pageIndex: i)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                PrimaryButton(title: "Continue") {
                    if page < 2 {
                        withAnimation { page += 1 }
                    } else {
                        completed = true
                    }
                }
                .padding(.horizontal, Theme.spacingLarge)
                .padding(.bottom, Theme.spacingXLarge)
            }
        }
    }
}

struct OnboardingPageView: View {
    let title: String
    let subtitle: String
    let pageIndex: Int

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingXLarge) {
                Spacer(minLength: 40)
                boardIllustration
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer(minLength: 24)
            }
        }
    }

    private var boardIllustration: some View {
        let cols = 4
        return VStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<cols, id: \.self) { col in
                        RoundedRectangle(cornerRadius: 4)
                            .fill((row + col) % 2 == 1 ? Color("SurfaceCard") : Color("BoardLight"))
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius + 4)
                .fill(Color("DeepForest"))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius + 4)
                        .stroke(
                            LinearGradient(
                                colors: [Color("ElectricClover").opacity(0.35), Color("WarmGold").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color("ElectricClover").opacity(0.15), radius: 20, x: 0, y: 8)
        )
    }
}
