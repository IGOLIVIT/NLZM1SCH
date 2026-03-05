//
//  HomeView.swift
//  NLZM1SCH
//

import SwiftUI

struct HomeView: View {
    @Binding var path: [Route]
    @ObservedObject var progress: ProgressStore

    var body: some View {
        ZStack {
            AppBackgroundView(style: .default)
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingLarge) {
                    Text("Today's tip")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    Text(TodaysFocus.current)
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                        .padding(Theme.spacingMedium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardBackground()
                        .padding(.horizontal)

                    Text("Play")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.horizontal)
                        .padding(.top, Theme.spacingSmall)

                    HStack(spacing: Theme.spacingMedium) {
                        HomeActionCard(accent: Color("ElectricClover"), icon: "lightbulb.fill") {
                            path = path + [.play(hints: true)]
                        } content: {
                            VStack(alignment: .leading, spacing: Theme.spacingSmall) {
                                Text("Play with hints")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("TextPrimary"))
                                Text("Suggested moves on")
                                    .font(.caption)
                                    .foregroundColor(Color("TextSecondary"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        HomeActionCard(accent: Color("WarmGold"), icon: "flame.fill") {
                            path = path + [.play(hints: false)]
                        } content: {
                            VStack(alignment: .leading, spacing: Theme.spacingSmall) {
                                Text("Play without hints")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("TextPrimary"))
                                Text("No suggestions")
                                    .font(.caption)
                                    .foregroundColor(Color("TextSecondary"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)

                    HomeActionCard(accent: Color("ArcCyan"), icon: "book.closed.fill", fullWidth: true) {
                        path = path + [.learn]
                    } content: {
                        HStack {
                            VStack(alignment: .leading, spacing: Theme.spacingSmall) {
                                Text("Learn")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("TextPrimary"))
                                Text("Rules and tactics")
                                    .font(.caption)
                                    .foregroundColor(Color("TextSecondary"))
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)

                    HomeActionCard(accent: Color("WarmGold"), icon: "list.bullet.rectangle.fill", fullWidth: true) {
                        path = path + [.rules]
                    } content: {
                        HStack {
                            Text("Rules")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("TextPrimary"))
                            Spacer()
                        }
                    }
                    .padding(.horizontal)

                    HomeActionCard(accent: Color("TextSecondary"), icon: "gearshape.fill", fullWidth: true) {
                        path = path + [.settings]
                    } content: {
                        HStack {
                            Text("Settings")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("TextPrimary"))
                            Spacer()
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 24)
                }
                .padding(.vertical, Theme.spacingLarge)
            }
        }
        .navigationTitle("Hub")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Home action card (bright, high-contrast)
private struct HomeActionCard<Content: View>: View {
    let accent: Color
    var icon: String? = nil
    var fullWidth: Bool = false
    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 0) {
                accentBar
                if let icon = icon {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(accent.opacity(0.25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(accent, lineWidth: 2)
                            )
                        Image(systemName: icon)
                            .font(.system(size: fullWidth ? 22 : 18, weight: .semibold))
                            .foregroundColor(accent)
                    }
                    .frame(width: fullWidth ? 48 : 44, height: fullWidth ? 48 : 44)
                    .padding(.leading, Theme.spacingSmall)
                    .padding(.trailing, Theme.spacingSmall)
                    .padding(.vertical, Theme.spacingMedium)
                }
                content
                    .padding(.vertical, Theme.spacingMedium)
                    .padding(.trailing, Theme.spacingLarge)
                if fullWidth {
                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                    .stroke(borderGradient, lineWidth: 2.5)
            )
            .shadow(color: accent.opacity(0.35), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(HomeCardButtonStyle())
    }

    private var background: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .fill(Color("SurfaceCard").opacity(0.95))
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .fill(
                    LinearGradient(
                        colors: [
                            accent.opacity(0.12),
                            accent.opacity(0.02),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    private var accentBar: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [accent.opacity(0.95), accent.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 5)
            .frame(maxHeight: .infinity)
    }

    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                accent,
                accent.opacity(0.7),
                accent.opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct HomeCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
