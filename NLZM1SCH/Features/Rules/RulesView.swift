//
//  RulesView.swift
//  NLZM1SCH
//

import SwiftUI

struct RulesView: View {
    var body: some View {
        ZStack {
            AppBackgroundView(style: .default)
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingLarge) {
                    ForEach(RulesGlossary.entries) { entry in
                        VStack(alignment: .leading, spacing: Theme.spacingMedium) {
                            Text(entry.title)
                                .font(.headline)
                                .foregroundColor(Color("ElectricClover"))
                            RuleDemoView(ruleId: entry.id)
                                .frame(maxWidth: .infinity)
                            Text(entry.body)
                                .font(.subheadline)
                                .foregroundColor(Color("TextSecondary"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Theme.spacingMedium)
                        .appCardBackground()
                        .padding(.horizontal)
                    }
                    Spacer(minLength: 24)
                }
                .padding(.vertical, Theme.spacingLarge)
            }
        }
        .navigationTitle("Rules")
        .navigationBarTitleDisplayMode(.inline)
    }
}
