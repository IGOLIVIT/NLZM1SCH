//
//  RuleDemoView.swift
//  NLZM1SCH
//

import SwiftUI

/// Non-interactive looping demo for a rule. Pass rule id to show the matching animation.
struct RuleDemoView: View {
    let ruleId: String
    private let cellSize: CGFloat = 28
    private let demoSize: CGFloat = 4

    var body: some View {
        Group {
            switch ruleId {
            case "board": BoardDemoView(cellSize: cellSize)
            case "move": MoveDemoView(cellSize: cellSize)
            case "capture": CaptureDemoView(cellSize: cellSize)
            case "king": KingDemoView(cellSize: cellSize)
            default: EmptyView()
            }
        }
        .frame(height: ruleId == "board" ? 140 : 120)
        .allowsHitTesting(false)
    }
}

// MARK: - Board demo (starting position, dark squares highlighted)
private struct BoardDemoView: View {
    let cellSize: CGFloat
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<4, id: \.self) { col in
                        let isDark = (row + col) % 2 == 1
                        ZStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(isDark ? Color("SurfaceCard").opacity(pulse ? 0.9 : 0.6) : Color("BoardLight"))
                            if isDark && row < 2 {
                                Circle()
                                    .fill(Color("DeepForest"))
                                    .frame(width: cellSize * 0.5, height: cellSize * 0.5)
                            }
                            if isDark && row >= 2 {
                                Circle()
                                    .fill(Color("BoardLight"))
                                    .frame(width: cellSize * 0.5, height: cellSize * 0.5)
                            }
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
        .padding(8)
        .background(Color("DeepForest"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}

// MARK: - Move demo (piece moves diagonally forward and back)
private struct MoveDemoView: View {
    let cellSize: CGFloat
    @State private var moved = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 2 dark squares diagonal
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    darkSquare
                    RoundedRectangle(cornerRadius: 3).fill(Color("BoardLight")).frame(width: cellSize, height: cellSize)
                }
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3).fill(Color("BoardLight")).frame(width: cellSize, height: cellSize)
                    darkSquare
                }
            }
            .padding(8)
            .background(Color("DeepForest"))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Circle()
                .fill(Color("BoardLight"))
                .overlay(Circle().stroke(Color("WarmGold"), lineWidth: 1.5))
                .frame(width: cellSize * 0.7, height: cellSize * 0.7)
                .offset(x: 8 + (moved ? cellSize + 2 : 0), y: 8 + (moved ? cellSize + 2 : 0))
        }
        .frame(width: cellSize * 2 + 20, height: cellSize * 2 + 20)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.5)) { moved = true }
        }
    }

    private var darkSquare: some View {
        RoundedRectangle(cornerRadius: 3).fill(Color("SurfaceCard")).frame(width: cellSize, height: cellSize)
    }
}

// MARK: - Capture demo (single jump then double jump: two pieces in one turn)
private struct CaptureDemoView: View {
    let cellSize: CGFloat

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.08)) { ctx in
            CaptureDemoContent(cellSize: cellSize, time: ctx.date.timeIntervalSinceReferenceDate)
        }
        .frame(width: cellSize + 20, height: cellSize * 5 + 24)
    }
}

private struct CaptureDemoContent: View {
    let cellSize: CGFloat
    let time: TimeInterval
    private let cycle: Double = 4.5

    private var dy: CGFloat { cellSize + 2 }
    private var phase: Int {
        let t = time.truncatingRemainder(dividingBy: cycle)
        if t < 0.8 { return 0 }
        if t < 1.8 { return 1 }
        if t < 2.8 { return 2 }
        if t < 3.8 { return 3 }
        return 4
    }
    private var jump1Progress: CGFloat {
        let t = time.truncatingRemainder(dividingBy: cycle)
        if t < 0.8 { return 0 }
        if t < 1.8 { return CGFloat((t - 0.8) / 1.0) }
        return 1
    }
    private var jump2Progress: CGFloat {
        let t = time.truncatingRemainder(dividingBy: cycle)
        if t < 2.8 { return 0 }
        if t < 3.8 { return CGFloat((t - 2.8) / 1.0) }
        return 1
    }
    private var pieceY: CGFloat {
        let y0: CGFloat = 8
        if phase <= 1 { return y0 + dy * jump1Progress * 2 }
        return y0 + dy * 2 + dy * jump2Progress * 2
    }
    private var showEnemy1: Bool { phase == 0 || (phase == 1 && jump1Progress < 0.5) }
    private var showEnemy2: Bool { phase <= 2 || (phase == 3 && jump2Progress < 0.5) }
    private var enemy1Opacity: Double { phase == 1 ? 1 - Double(jump1Progress) * 2 : 1 }
    private var enemy2Opacity: Double { phase == 3 ? 1 - Double(jump2Progress) * 2 : 1 }
    private var y0: CGFloat { 8 }
    private var y1: CGFloat { y0 + dy }
    private var y2: CGFloat { y0 + dy * 2 }
    private var y3: CGFloat { y0 + dy * 3 }
    private var y4: CGFloat { y0 + dy * 4 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { _ in darkSq }
            }
            .padding(8)
            .background(Color("DeepForest"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            Circle()
                .fill(Color("BoardLight"))
                .overlay(Circle().stroke(Color("WarmGold"), lineWidth: 1.5))
                .frame(width: cellSize * 0.65, height: cellSize * 0.65)
                .offset(x: 8 + (cellSize - cellSize * 0.65) / 2, y: pieceY)
            if showEnemy1 {
                Circle()
                    .fill(Color("DeepForest"))
                    .overlay(Circle().stroke(Color("ElectricClover"), lineWidth: 1.5))
                    .frame(width: cellSize * 0.65, height: cellSize * 0.65)
                    .offset(x: 8 + (cellSize - cellSize * 0.65) / 2, y: y1)
                    .opacity(enemy1Opacity)
            }
            if showEnemy2 {
                Circle()
                    .fill(Color("DeepForest"))
                    .overlay(Circle().stroke(Color("ElectricClover"), lineWidth: 1.5))
                    .frame(width: cellSize * 0.65, height: cellSize * 0.65)
                    .offset(x: 8 + (cellSize - cellSize * 0.65) / 2, y: y3)
                    .opacity(enemy2Opacity)
            }
        }
    }

    private var darkSq: some View {
        RoundedRectangle(cornerRadius: 3).fill(Color("SurfaceCard")).frame(width: cellSize, height: cellSize)
    }
    private var lightSq: some View {
        RoundedRectangle(cornerRadius: 3).fill(Color("BoardLight")).frame(width: cellSize, height: cellSize)
    }
}

// MARK: - King demo (piece reaches back row, crown appears)
private struct KingDemoView: View {
    let cellSize: CGFloat
    @State private var animProgress: CGFloat = 0

    private var pieceY: CGFloat {
        let startY: CGFloat = 8 + cellSize + 2
        let endY: CGFloat = 8
        return startY - (startY - endY) * animProgress
    }

    private var crownScale: CGFloat {
        animProgress > 0.6 ? min(1, (animProgress - 0.6) / 0.4) : 0
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3).fill(Color("SurfaceCard")).frame(width: cellSize, height: cellSize)
                    RoundedRectangle(cornerRadius: 3).fill(Color("BoardLight")).frame(width: cellSize, height: cellSize)
                }
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3).fill(Color("BoardLight")).frame(width: cellSize, height: cellSize)
                    RoundedRectangle(cornerRadius: 3).fill(Color("SurfaceCard")).frame(width: cellSize, height: cellSize)
                }
            }
            .padding(8)
            .background(Color("DeepForest"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            ZStack {
                Circle()
                    .fill(Color("BoardLight"))
                    .overlay(Circle().stroke(Color("WarmGold"), lineWidth: 1.5))
                    .frame(width: cellSize * 0.7, height: cellSize * 0.7)
                if crownScale > 0 {
                    Circle()
                        .stroke(Color("WarmGold"), lineWidth: 2)
                        .frame(width: cellSize * 0.35, height: cellSize * 0.35)
                        .scaleEffect(crownScale)
                }
            }
            .offset(x: 8, y: pieceY)
        }
        .frame(width: cellSize * 2 + 20, height: cellSize * 2 + 20)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.3)) { animProgress = 1 }
        }
    }
}
