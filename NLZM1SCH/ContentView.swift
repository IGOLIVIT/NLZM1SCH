//
//  ContentView.swift
//  NLZM1SCH
//
//  Created by IGOR on 03/03/2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted: Bool = false

    var body: some View {
        if onboardingCompleted {
            MainFlowView()
        } else {
            OnboardingView(completed: $onboardingCompleted)
        }
    }
}

#Preview {
    ContentView()
}
