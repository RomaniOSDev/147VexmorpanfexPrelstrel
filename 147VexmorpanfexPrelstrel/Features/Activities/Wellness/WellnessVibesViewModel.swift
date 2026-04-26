import Foundation
import SwiftUI
import Combine

struct WellExercise: Identifiable, Hashable, Codable {
    let id: String
    let systemSymbol: String
    let shortLabel: String
}

@MainActor
final class WellnessVibesViewModel: ObservableObject {
    enum Difficulty: String, CaseIterable, Identifiable {
        case light
        case balanced
        case full

        var id: String { rawValue }
        var title: String {
            switch self {
            case .light: return "Light"
            case .balanced: return "Balanced"
            case .full: return "Full"
            }
        }
    }

    static let catalog: [WellExercise] = [
        .init(id: "y1", systemSymbol: "figure.yoga", shortLabel: "Yoga flow"),
        .init(id: "b1", systemSymbol: "lungs", shortLabel: "Breath"),
        .init(id: "s1", systemSymbol: "figure.strengthtraining.traditional", shortLabel: "Stability"),
        .init(id: "w1", systemSymbol: "figure.walk", shortLabel: "Stroll"),
        .init(id: "m1", systemSymbol: "leaf.fill", shortLabel: "Quiet focus"),
        .init(id: "h1", systemSymbol: "drop.fill", shortLabel: "Hydration"),
    ]

    @Published var difficulty: Difficulty
    @Published var slots: [String?] = []
    @Published var bank: [String] = []
    @Published var isCompleteHoldAvailable: Bool = false
    @Published var activeDrag: String?

    var orderedTargets: [String] = []

    init(
        baseSessions: Int,
        preferredDifficulty: Difficulty = .balanced
    ) {
        self.baseSessions = baseSessions
        self.difficulty = preferredDifficulty
        rebuildChallenges()
    }

    var baseSessions: Int

    var totalSlots: Int { slots.count }

    var scheduleAlignmentPercent: Double {
        guard !orderedTargets.isEmpty else { return 0 }
        var c = 0
        for i in 0..<min(slots.count, orderedTargets.count) {
            if let t = slots[i], t == orderedTargets[i] { c += 1 }
        }
        return (Double(c) / Double(orderedTargets.count)) * 100.0
    }

    var starCountForCurrentPlan: Int {
        let r = correctnessScore
        if r >= 0.99 { return 3 }
        if r >= 0.80 { return 2 }
        if r >= 0.60 { return 1 }
        return 0
    }

    private var correctnessScore: Double {
        guard !slots.isEmpty else { return 0 }
        let n = min(slots.count, orderedTargets.count)
        if n == 0 { return 0 }
        var c = 0
        for i in 0..<n {
            if let s = slots[i], s == orderedTargets[i] { c += 1 }
        }
        return Double(c) / Double(orderedTargets.count)
    }

    var bankRemaining: [WellExercise] {
        bank.compactMap { id in Self.catalog.first { $0.id == id } }
    }

    func onAppear() { rebuildChallenges() }

    func onDifficultyChange() { rebuildChallenges() }

    func setSlotCountFromOutside(_ sessions: Int) {
        baseSessions = sessions
        rebuildChallenges()
    }

    func rebuildChallenges() {
        let dynamic = min(6, 3 + baseSessions / 2)
        let n = min(6, max(3, dynamic + diffExtra()))
        let selected = Array(Self.catalog.shuffled().prefix(n))
        orderedTargets = selected.map(\.id)
        slots = Array(repeating: nil, count: n)
        bank = selected.map(\.id)
        isCompleteHoldAvailable = false
    }

    private func diffExtra() -> Int {
        switch difficulty {
        case .light: return 0
        case .balanced: return 1
        case .full: return 2
        }
    }

    func moveFromBankToSlot(symbolId: String, index: Int) {
        guard index >= 0, index < slots.count else { return }
        if let pos = bank.firstIndex(of: symbolId) { bank.remove(at: pos) }
        if let existing = slots[index], !existing.isEmpty { bank.append(existing) }
        slots[index] = symbolId
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { }
    }

    func returnToBank(slotIndex index: Int) {
        guard index < slots.count, let v = slots[index] else { return }
        bank.append(v)
        slots[index] = nil
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { }
    }

    func evaluateFillState() {
        isCompleteHoldAvailable = slots.compactMap { $0 }.count == slots.count && !slots.isEmpty
    }
}
