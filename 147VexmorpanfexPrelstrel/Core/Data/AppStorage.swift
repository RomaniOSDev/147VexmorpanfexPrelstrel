import Foundation
import SwiftUI
import Combine

extension Notification.Name {
    static let lifestyleDataDidRefresh = Notification.Name("lifestyleDataDidRefresh")
}

@MainActor
final class LifestyleData: ObservableObject {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    @AppStorage("totalStarCount") var totalStarCount: Int = 0
    @AppStorage("wellnessPlan") var wellnessPlanRaw: String = "{}"
    @AppStorage("creativeWisdom") var creativeWisdomRaw: String = "{}"
    @AppStorage("connectionWeave") var connectionWeaveRaw: String = "{}"

    @AppStorage("sessionCalendarDayId") var sessionCalendarDayId: String = ""
    @AppStorage("unlockedActivityTier") var unlockedActivityTier: Int = 0

    /// `UserDefaults` + manual `objectWillChange` (not `@AppStorage`) so we never publish from SwiftUI’s @AppStorage bridge during a view update.
    private static let lifeExtraV1Key = "lifestyleExtraV1"
    private var lifeExtraV1: String {
        get { UserDefaults.standard.string(forKey: Self.lifeExtraV1Key) ?? "{}" }
        set { UserDefaults.standard.set(newValue, forKey: Self.lifeExtraV1Key) }
    }

    private var wellnessDecoded: WellnessPersistentState {
        get { (try? JSONDecoder().decode(WellnessPersistentState.self, from: Data(wellnessPlanRaw.utf8))) ?? WellnessPersistentState() }
        set {
            if let d = try? JSONEncoder().encode(newValue) {
                wellnessPlanRaw = String(data: d, encoding: .utf8) ?? "{}"
            }
        }
    }

    var wellnessState: WellnessPersistentState {
        get { wellnessDecoded }
        set { wellnessDecoded = newValue; objectWillChange.send() }
    }

    var creativeState: CreativePersistentState {
        get { (try? JSONDecoder().decode(CreativePersistentState.self, from: Data(creativeWisdomRaw.utf8))) ?? CreativePersistentState() }
        set {
            if let d = try? JSONEncoder().encode(newValue) {
                creativeWisdomRaw = String(data: d, encoding: .utf8) ?? "{}"
            }
            objectWillChange.send()
        }
    }

    var connectionState: ConnectionPersistentState {
        get { (try? JSONDecoder().decode(ConnectionPersistentState.self, from: Data(connectionWeaveRaw.utf8))) ?? ConnectionPersistentState() }
        set {
            if let d = try? JSONEncoder().encode(newValue) {
                connectionWeaveRaw = String(data: d, encoding: .utf8) ?? "{}"
            }
            objectWillChange.send()
        }
    }

    var habitHeroUnlocked: Bool { wellnessState.completedCount >= 6 }
    var creativeMavenUnlocked: Bool { creativeState.qualityRunCount >= 4 }
    var weaveSageUnlocked: Bool { connectionState.weeksCompletedWithThreeStars >= 1 }

    var wellnessSessions: Int { wellnessState.completedCount }
    var creativeSessions: Int { creativeState.sessionCount }
    var connectionWeaves: Int { connectionState.weaveSessionsCount }

    var extra: LifestyleExtraState {
        get { (try? JSONDecoder().decode(LifestyleExtraState.self, from: Data(lifeExtraV1.utf8))) ?? .empty }
        set {
            guard let d = try? JSONEncoder().encode(newValue) else { return }
            let s = String(data: d, encoding: .utf8) ?? "{}"
            if s == lifeExtraV1 { return }
            lifeExtraV1 = s
            Task { @MainActor in
                self.objectWillChange.send()
            }
        }
    }

    func addStars(_ n: Int) {
        let safe = max(0, n)
        totalStarCount = min(99999, totalStarCount + safe)
        recordStarsInIsoWeek(safe)
        postRefresh()
    }

    func setWellnessState(_ s: WellnessPersistentState) { wellnessState = s }

    func setCreativeState(_ s: CreativePersistentState) { creativeState = s }

    func setConnectionState(_ s: ConnectionPersistentState) { connectionState = s }

    func recordTierUnlock(tier: Int) {
        unlockedActivityTier = max(unlockedActivityTier, tier)
        postRefresh()
    }

    func currentCalendarDayId() -> String {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    func currentWeekId() -> String {
        let c = Calendar.current
        let y = c.component(.yearForWeekOfYear, from: Date())
        let w = c.component(.weekOfYear, from: Date())
        return "\(y)-\(w)"
    }

    @discardableResult
    func finalizeConnectionWeekIfNeeded() -> Int {
        var s = connectionState
        let now = currentWeekId()
        if s.weekId.isEmpty {
            s.weekId = now
            setConnectionState(s)
            return 0
        }
        if s.weekId == now { return 0 }
        let target = max(1, s.dailyTarget) * 7
        let t = s.freshTouchesThisWeek
        let ratio = target > 0 ? Double(t) / Double(target) : 0
        var earn = 0
        if ratio >= 0.99 { earn = 3 } else if ratio >= 0.75 { earn = 2 } else if ratio >= 0.5 { earn = 1 } else { earn = 0 }
        addStars(earn)
        s.carryStarsPending = earn
        s.weekStarHistory.append(earn)
        if earn == 3 { s.weeksCompletedWithThreeStars += 1 }
        s.freshTouchesThisWeek = 0
        s.weekId = now
        setConnectionState(s)
        return earn
    }

    func postRefresh() {
        objectWillChange.send()
        NotificationCenter.default.post(name: .lifestyleDataDidRefresh, object: nil)
    }

    func resetAllProgress() {
        hasSeenOnboarding = true
        totalStarCount = 0
        wellnessPlanRaw = "{}"
        creativeWisdomRaw = "{}"
        connectionWeaveRaw = "{}"
        sessionCalendarDayId = ""
        unlockedActivityTier = 0
        lifeExtraV1 = "{}"
        postRefresh()
    }
}

struct WellnessPersistentState: Codable, Equatable {
    var completedCount: Int = 0
    var lastDayMarker: String = ""
    var lastStarReward: Int = 0
    var bestFullness: Double = 0
}

struct CreativePersistentState: Codable, Equatable {
    var sessionCount: Int = 0
    var lastPackDay: String = ""
    var lastStarReward: Int = 0
    var qualityRunCount: Int = 0
    var lastJournalSeconds: Int = 0
}

struct ConnectionPersistentState: Codable, Equatable {
    struct WeaveItem: Codable, Equatable, Identifiable {
        var id: UUID
        var title: String
        var kind: String
    }

    var people: [WeaveItem] = []
    var focusNotes: [WeaveItem] = []
    var dailyTarget: Int = 2
    var weekId: String = ""
    var freshTouchesThisWeek: Int = 0
    var carryStarsPending: Int = 0
    var weaveSessionsCount: Int = 0
    var lastWeekTallySerialized: String = ""
    var weeksCompletedWithThreeStars: Int = 0
    var weekStarHistory: [Int] = []
}
