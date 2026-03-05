//
//  PrimaryButton.swift
//  NLZM1SCH
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var style: Style = .primary

    enum Style {
        case primary
        case secondary
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(style == .primary ? Color("EmeraldNight") : Color("TextPrimary"))
                .frame(maxWidth: .infinity)
                .frame(minHeight: Theme.buttonHeight)
                .padding(.horizontal, Theme.spacingLarge)
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(style == .primary ? Color("ElectricClover") : Color("SurfaceCard"))
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        PrimaryButton(title: title, action: action, style: .secondary)
    }
}
