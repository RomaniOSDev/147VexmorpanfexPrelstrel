import Foundation
import SwiftUI

extension LifestyleData {
    // MARK: - Week + streak

    func applyIsoWeekRollover() {
        var e = extra
        let w = currentWeekId()
        if e.thisIsoYearWeek != w {
            if !e.thisIsoYearWeek.isEmpty {
                if e.thisWeekWeaveCompletions > 0 {
                    e.consecutiveWeaveWeeks += 1
                } else {
                    e.consecutiveWeaveWeeks = 0
                }
            }
            e.thisIsoYearWeek = w
            e.starsEarnedInIsoWeek = 0
            e.weekActivityDayKeys = []
            e.weekTouchSessions = 0
            e.thisWeekWeaveCompletions = 0
        } else if e.thisIsoYearWeek.isEmpty {
            e.thisIsoYearWeek = w
        }
        extra = e
        tryGrantBadges()
    }

    func recordStarsInIsoWeek(_ n: Int) {
        applyIsoWeekRollover()
        var e = extra
        e.starsEarnedInIsoWeek += n
        extra = e
    }

    /// Any meaningful action: wellness, creative, weave, cards, micro done.
    func registerActivity() {
        applyIsoWeekRollover()
        var e = extra
        let day = currentCalendarDayId()
        e.weekTouchSessions += 1
        if !e.weekActivityDayKeys.contains(day) {
            e.weekActivityDayKeys.append(day)
        }
        if e.lastActivityDay == day {
            extra = e
            tryGrantBadges()
            return
        }
        if e.lastActivityDay.isEmpty {
            e.dayStreak = 1
        } else {
            e.dayStreak = Self.isPreviousCalendarDay(before: e.lastActivityDay, than: day) ? e.dayStreak + 1 : 1
        }
        e.lastActivityDay = day
        e.bestStreak = max(e.bestStreak, e.dayStreak)
        extra = e
        tryGrantBadges()
    }

    static func isPreviousCalendarDay(before a: String, than b: String) -> Bool {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.dateFormat = "yyyy-MM-dd"
        guard let da = f.date(from: a), let db = f.date(from: b) else { return false }
        let cal = Calendar.current
        guard let dayAfterA = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: da)) else { return false }
        return cal.isDate(db, inSameDayAs: dayAfterA)
    }

    func tryGrantBadges() {
        var e = extra
        func g(_ k: String) {
            if !e.badgeFired.contains(k) { e.badgeFired.append(k) }
        }
        if e.dayStreak >= 7 { g("streak7") }
        if creativeState.sessionCount >= 20 { g("creative20") }
        if e.consecutiveWeaveWeeks >= 4 { g("weave4") }
        extra = e
    }

    func registerWeaveCompletion() {
        applyIsoWeekRollover()
        var e = extra
        e.thisWeekWeaveCompletions += 1
        extra = e
        tryGrantBadges()
    }

    // MARK: - Text cards

    func setQuietLines(_ s: String, forDay day: String) {
        var e = extra
        let t = String(s.prefix(500))
        e.quietLinesByDay[day] = t
        extra = e
    }

    func setOnePhrase(_ s: String, forDay day: String) {
        var e = extra
        e.onePhraseByDay[day] = String(s.prefix(200))
        extra = e
    }

    /// Deterministic for a calendar day, no side effects (must not write while SwiftUI is updating views).
    func currentMicroIndex(forDay day: String) -> Int {
        let h = (day + "micro").hashValue
        return abs(h) % max(1, MicroChallengeProvider.pool.count)
    }

    func setMicroDone(_ done: Bool, day: String) {
        var e = extra
        e.microDoneByDay[day] = done
        extra = e
    }

    // MARK: - Archive

    func appendCreativeArchive(day: String, answers: [String]) {
        var e = extra
        let nonEmpty = answers
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !nonEmpty.isEmpty else { return }
        var block = e.creativeTextArchiveByDay[day] ?? []
        if !block.isEmpty { block.append("·") }
        block.append(contentsOf: nonEmpty)
        e.creativeTextArchiveByDay[day] = block
        extra = e
    }

    func appendWeaveSnapshot(day: String) {
        var e = extra
        let c = connectionState
        let snap = WeaveArchiveSnapshot(
            people: c.people.map(\.title),
            focusLines: c.focusNotes.map(\.title)
        )
        var arr = e.weaveTextArchiveByDay[day] ?? []
        arr.append(snap)
        e.weaveTextArchiveByDay[day] = arr
        extra = e
    }

    // MARK: - Reminders (stored; scheduling in LocalNotificationService)

    func setReminder(_ on: Bool, hour: Int, minute: Int) {
        var e = extra
        e.reminderEnabled = on
        e.reminderHour = max(0, min(23, hour))
        e.reminderMinute = max(0, min(59, minute))
        if on { e.wasAskedNotificationPermission = true }
        extra = e
    }

    // MARK: - UI helpers

    var hasStreak7Badge: Bool { extra.badgeFired.contains("streak7") }
    var hasCreative20Badge: Bool { extra.badgeFired.contains("creative20") }
    var hasWeave4WeekBadge: Bool { extra.badgeFired.contains("weave4") }

    /// Plain text for paste / share; no account or cloud.
    func weeklySummaryExportString() -> String {
        let e = extra
        let wk = currentWeekId()
        let dayKeys = e.weekActivityDayKeys.sorted()
        let dayLine = dayKeys.isEmpty
            ? "0"
            : "\(dayKeys.count) day(s) with action"
        return """
        Week ref: \(wk)
        Stars this ISO week: \(e.starsEarnedInIsoWeek)
        Active days: \(dayLine) (touch this week: \(e.weekTouchSessions))
        Weave check-ins (week): \(e.thisWeekWeaveCompletions)
        Run streak: \(e.dayStreak) day(s) (best: \(e.bestStreak))
        Weave week streak: \(e.consecutiveWeaveWeeks)
        """
    }
}
