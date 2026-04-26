import Foundation
import SwiftUI
import Combine

enum MainTab: String, CaseIterable, Identifiable {
    case home
    case discover
    case moments
    case selfSpace

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .discover: return "Discover"
        case .moments: return "Moments"
        case .selfSpace: return "Self"
        }
    }

    var symbolName: String {
        switch self {
        case .home: return "house.fill"
        case .discover: return "sparkle.magnifyingglass"
        case .moments: return "note.text"
        case .selfSpace: return "person.crop.circle"
        }
    }
}

final class AppShellState: ObservableObject {
    @Published var selected: MainTab = .home

    func openSelf() {
        selected = .selfSpace
    }

    func openMoments() {
        selected = .moments
    }
}
