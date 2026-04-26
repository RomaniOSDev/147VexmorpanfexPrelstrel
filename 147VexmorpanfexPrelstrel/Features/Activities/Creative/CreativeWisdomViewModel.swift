import Foundation
import SwiftUI
import Combine

@MainActor
final class CreativeWisdomViewModel: ObservableObject {
    struct Card: Identifiable {
        let id: Int
        let title: String
        let questions: [String]
    }

    @Published var answers: [[String]]
    @Published var elapsed: Int = 0

    private var timer: AnyCancellable?
    private let startToken: String

    let pack: [Card]

    init(dayId: String) {
        self.startToken = dayId
        self.pack = Self.buildPack(seed: dayId)
        self.answers = self.pack.map { c in
            [String](repeating: "", count: c.questions.count)
        }
    }

    func setAnswer(card: Int, line: Int, value: String) {
        guard card < answers.count, line < answers[card].count else { return }
        var row = answers[card]
        row[line] = value
        answers[card] = row
    }


    func onAppear() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsed += 1
            }
    }

    func onDisappear() { timer = nil }

    func resetSession() {
        answers = pack.map { [String](repeating: "", count: $0.questions.count) }
        elapsed = 0
    }

    var answeredCount: Int {
        answers.flatMap { $0 }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count
    }

    var starResult: Int {
        let a = answers.flatMap { $0 }
        let n = a
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count
        if n < 9 { return 0 }
        if n < 15 { return 1 }
        if elapsed <= 10 * 60 { return 3 }
        return 2
    }

    func autosave(into data: inout CreativePersistentState) {
        data.lastPackDay = startToken
        data.lastJournalSeconds = max(data.lastJournalSeconds, elapsed)
    }

    private static func buildPack(seed: String) -> [Card] {
        func h(_ a: String, _ b: String) -> Int {
            var s = Hasher()
            s.combine(a)
            s.combine(b)
            return s.finalize()
        }
        let t1 = mod3(h(seed, "alpha"))
        let t2 = mod3(h(seed, "beta"))
        let t3 = mod3(h(String(h(seed, "alpha")), "gamma2"))
        return [
            Card(
                id: 0, title: "Gentle \(["Spark", "Bloom", "Lift"][t1]) of Curiosity",
                questions: dayQuestions(shift: 0, seed: seed)
            ),
            Card(
                id: 1, title: "Quiet \(["Inquiry", "Wander", "Nudge"][t2])",
                questions: dayQuestions(shift: 1, seed: seed)
            ),
            Card(
                id: 2, title: "Reflective \(["Trio", "Arc", "Band"][t3])",
                questions: dayQuestions(shift: 2, seed: seed)
            ),
        ]
    }

    private static func mod3(_ n: Int) -> Int {
        var v = n % 3
        if v < 0 { v += 3 }
        return v
    }

    private static func dayQuestions(shift: Int, seed: String) -> [String] {
        var hasher = Hasher()
        hasher.combine(seed)
        hasher.combine(shift)
        var v = hasher.finalize() % 3
        if v < 0 { v += 3 }
        let pick = v
        let base: [[String]] = [
            [
                "Name one color that best fits your mood, and one word that would pair with it.",
                "List two calm sounds you can hear, name them quietly to yourself, then one word that ties them together.",
                "Name one object near you, then a feeling it suggests without overthinking the words.",
                "Name one person you can thank today, and a simple reason, even if the reason is very small.",
                "Name one way you can lower noise for a few minutes, then check if that is realistic today.",
            ],
            [
                "Note one line you could write as a one-line caption for the moment you are in right now.",
                "Pick one object and describe a texture with two words, then a third that ties them as a small phrase.",
                "Write one line about a place you can picture easily, and one adjective to describe the air there.",
                "Name one plan you can shrink into a 10 minute task, and write that task as a line.",
                "Name one line about what you are hoping for today, in plain words without judgment about how big it is.",
            ],
            [
                "Name one line about a habit you want to nudge, then one word that is kind about that nudge.",
                "Write a line that begins with the words \"Today I will,\" then stop after one more breath if it feels like enough.",
                "Name one line about a skill you are glad you have, even a small one.",
                "Name one person or role that helps you feel steady, and one line about a healthy boundary you can keep with care.",
                "Name one way you can close the day with a calm ritual, in one or two short lines at most.",
            ],
        ]
        return base[(pick + shift) % 3]
    }
}
