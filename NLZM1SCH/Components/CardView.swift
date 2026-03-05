//
//  CardView.swift
//  NLZM1SCH
//

import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    var action: (() -> Void)?

    init(action: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .fill(Color("SurfaceCard").opacity(0.88))
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("ElectricClover").opacity(0.06),
                            Color.clear,
                            Color("WarmGold").opacity(0.03)
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
    }

    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    content
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Theme.spacingLarge)
                        .background(cardBackground)
                }
                .buttonStyle(.plain)
            } else {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.spacingLarge)
                    .background(cardBackground)
            }
        }
    }
}
