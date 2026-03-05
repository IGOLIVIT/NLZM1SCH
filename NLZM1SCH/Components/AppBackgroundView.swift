//
//  AppBackgroundView.swift
//  NLZM1SCH
//

import SwiftUI

struct AppBackgroundView: View {
    var style: Style = .default

    enum Style {
        case `default`
        case game
        case card
    }

    var body: some View {
        ZStack {
            baseGradient
            glowOrbs(style: style)
            if style == .default || style == .card {
                diagonalLines
                dotTexture
            }
            if style == .game {
                gameCenterGlow
            }
            vignette
        }
        .ignoresSafeArea()
    }

    private var baseGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("DeepForest"),
                    Color("EmeraldNight"),
                    Color("SurfaceDark"),
                    Color("DeepForest")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            LinearGradient(
                colors: [
                    Color("SurfaceDark").opacity(0.4),
                    Color.clear,
                    Color("ElectricClover").opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func glowOrbs(style: Style) -> some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("ElectricClover").opacity(0.22),
                                Color("ElectricClover").opacity(0.06),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: w * 0.5
                        )
                    )
                    .frame(width: w * 1.2, height: w * 1.2)
                    .blur(radius: 60)
                    .offset(x: -w * 0.25, y: -h * 0.1)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("WarmGold").opacity(0.18),
                                Color("WarmGold").opacity(0.04),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: w * 0.45
                        )
                    )
                    .frame(width: w * 1.0, height: w * 1.0)
                    .blur(radius: 70)
                    .offset(x: w * 0.35, y: h * 0.35)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("ArcCyan").opacity(0.12),
                                Color("ArcCyan").opacity(0.02),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: w * 0.4
                        )
                    )
                    .frame(width: w * 0.9, height: w * 0.9)
                    .blur(radius: 55)
                    .offset(x: w * 0.1, y: h * 0.7)
            }
        }
    }

    private var gameCenterGlow: some View {
        GeometryReader { geo in
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color("ElectricClover").opacity(0.06),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.6
                    )
                )
                .frame(width: geo.size.width * 1.2, height: geo.size.height * 0.7)
                .blur(radius: 80)
                .position(x: geo.size.width * 0.5, y: geo.size.height * 0.45)
        }
    }

    private var diagonalLines: some View {
        GeometryReader { geo in
            let size = max(geo.size.width, geo.size.height) * 1.5
            Canvas { context, _ in
                let step: CGFloat = 28
                for i in stride(from: -size, to: size * 2, by: step) {
                    var path = Path()
                    path.move(to: CGPoint(x: i, y: -size))
                    path.addLine(to: CGPoint(x: i + size * 2, y: size * 2))
                    context.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [
                                Color("ElectricClover").opacity(0),
                                Color("ElectricClover").opacity(0.04),
                                Color("ElectricClover").opacity(0.06),
                                Color("ElectricClover").opacity(0.04),
                                Color("ElectricClover").opacity(0)
                            ]),
                            startPoint: CGPoint(x: 0, y: 0),
                            endPoint: CGPoint(x: size, y: size)
                        ),
                        lineWidth: 1
                    )
                }
            }
            .rotationEffect(.degrees(-25))
            .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.1)
        }
    }

    private var dotTexture: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let step: CGFloat = 20
                for x in stride(from: 0, to: size.width + step, by: step) {
                    for y in stride(from: 0, to: size.height + step, by: step) {
                        let alpha = 0.03 + (sin(x * 0.02) + cos(y * 0.02)) * 0.02
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: 1.5, height: 1.5)),
                            with: .color(Color("BoardLight").opacity(max(0, alpha)))
                        )
                    }
                }
            }
        }
    }

    private var vignette: some View {
        RadialGradient(
            colors: [
                Color.clear,
                Color.clear,
                Color("DeepForest").opacity(0.5)
            ],
            center: .center,
            startRadius: 0,
            endRadius: 600
        )
    }
}

struct CardBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                        .fill(Color("SurfaceCard").opacity(0.88))
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("ElectricClover").opacity(0.08),
                                    Color.clear,
                                    Color("WarmGold").opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color("ElectricClover").opacity(0.4),
                                    Color("WarmGold").opacity(0.2),
                                    Color("ElectricClover").opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
    }
}

extension View {
    func appCardBackground() -> some View {
        modifier(CardBackgroundModifier())
    }
}
