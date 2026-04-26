import Foundation

/// Extra persistence (one JSON in AppStorage) — daily cards, archive, streak, weekly tallies, badges.
struct LifestyleExtraState: Codable, Equatable {
    var quietLinesByDay: [String: String] = [:]
    var onePhraseByDay: [String: String] = [:]
    var microIndexByDay: [String: Int] = [:]
    var microDoneByDay: [String: Bool] = [:]
    var lastActivityDay: String = ""
    var dayStreak: Int = 0
    var bestStreak: Int = 0
    var lastIsoYearWeek: String = ""
    var starsEarnedInIsoWeek: Int = 0
    var activeSessionDaysInIsoWeek: Int = 0
    var weekActivityDayKeys: [String] = []
    var weekTouchSessions: Int = 0
    var creativeTextArchiveByDay: [String: [String]] = [:]
    /// Newest last; each `Complete daily weave` appends a snapshot for that day.
    var weaveTextArchiveByDay: [String: [WeaveArchiveSnapshot]] = [:]
    var reminderEnabled: Bool = false
    var reminderHour: Int = 9
    var reminderMinute: Int = 0
    var wasAskedNotificationPermission: Bool = false
    var badgeFired: [String] = []
    var thisIsoYearWeek: String = ""
    var thisWeekWeaveCompletions: Int = 0
    var consecutiveWeaveWeeks: Int = 0
}

struct WeaveArchiveSnapshot: Codable, Equatable {
    var people: [String]
    var focusLines: [String]
}

struct MicroChallengeProvider {
    static let pool: [String] = [
        "Tidy a single surface in two minutes, then move on with care.",
        "Sip a glass of water in silence, notice two breaths after.",
        "Send one message that simply checks in, without a big ask attached.",
        "Name one object you are grateful to have nearby today.",
        "Open a window or step out for 60 seconds of open air, if the day allows.",
        "Stretch arms overhead twice, with slow shoulders and a soft neck.",
        "Tidy a cable or pocket that always annoys you in a small, safe way.",
        "Dim one light or lower volume for a calmer 10 minutes before sleep.",
    ]
}

extension LifestyleExtraState {
    static var empty: LifestyleExtraState { .init() }
}
