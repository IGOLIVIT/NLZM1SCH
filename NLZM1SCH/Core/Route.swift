//
//  Route.swift
//  NLZM1SCH
//

import Foundation

enum Route: Hashable {
    case learn
    case learnLesson(id: String)
    case play(hints: Bool)
    case rules
    case settings
    case onboarding
}
