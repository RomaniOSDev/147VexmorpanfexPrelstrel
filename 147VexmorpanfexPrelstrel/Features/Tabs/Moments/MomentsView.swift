import SwiftUI

struct MomentsView: View {
    @EnvironmentObject private var lifestyle: LifestyleData
    @Environment(\.scenePhase) private var scenePhase
    @State private var dayId: String = ""
    @State private var quietText: String = ""
    @State private var linePhrase: String = ""
    @State private var showQuietSaved: Bool = false
    @State private var showPhraseSaved: Bool = false

    private let prompts: [String] = [
        "Name one good enough moment from the last 24 hours.",
        "Name one way you can lower noise for 10 minutes today.",
        "Name one way you are learning without rushing the outcome.",
        "Name a soft boundary you can set with a kind tone, then keep it for one short stretch.",
    ]

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quiet two or three lines")
                        .appPrimaryLineStyle()
                        .font(.subheadline)
                    ZStack(alignment: .topLeading) {
                        if quietText.isEmpty {
                            Text("1–3 lines, local only, no account.")
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary.opacity(0.8))
                                .padding(10)
                        }
                        TextField("", text: $quietText, axis: .vertical)
                            .appPrimaryLineStyle()
                            .textFieldStyle(.plain)
                            .lineLimit(1...3)
                    }
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(AppFill.card)
                            .shadow(color: .black.opacity(0.18), radius: 5, y: 2)
                    }
                    HStack {
                        Spacer()
                        Button("Save to today’s card") {
                            saveQuiet()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.appPrimary)
                    }
                    if showQuietSaved { Text("Saved for \(dayId).").font(.caption).foregroundStyle(Color.appTextSecondary) }
                }
                .appInsetListRow()
            } header: { Text("Quiet two lines") } footer: {
                Text("One local card a day, stored on device only.")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today in one line")
                        .appPrimaryLineStyle()
                        .font(.subheadline)
                    TextField("A single line that fits today, resets at the next day.", text: $linePhrase)
                        .appPrimaryLineStyle()
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(AppFill.card)
                                .shadow(color: .black.opacity(0.18), radius: 5, y: 2)
                        }
                    HStack {
                        Spacer()
                        Button("Save this line") {
                            savePhrase()
                        }
                        .buttonStyle(.bordered)
                        .tint(.appPrimary)
                    }
                    if showPhraseSaved { Text("Noted for \(dayId).").font(.caption).foregroundStyle(Color.appTextSecondary) }
                }
                .appInsetListRow()
            } header: { Text("Today in one phrase") } footer: {
                Text("Same day key as the creative run; new calendar day, empty field.")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Section {
                ForEach(Array(prompts.enumerated()), id: \.offset) { i, p in
                    NavigationLink {
                        MomentDetailView(
                            index: i,
                            text: p,
                            totalPrompts: prompts.count
                        )
                    } label: {
                        Text(p)
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextPrimary)
                            .multilineTextAlignment(.leading)
                    }
                    .appInsetListRow()
                }
            } footer: {
                Text("Tap a line to go deeper on your time.")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .appRootScrollBackground()
        .tint(.appPrimary)
        .preferredColorScheme(.dark)
        .navigationTitle("Moments")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { refreshFromDay() }
        .onChange(of: scenePhase) { _, new in
            if new == .active { refreshFromDay() }
        }
    }

    private func refreshFromDay() {
        let d = lifestyle.currentCalendarDayId()
        guard d != dayId else { return }
        dayId = d
        let e = lifestyle.extra
        quietText = e.quietLinesByDay[dayId] ?? ""
        linePhrase = e.onePhraseByDay[dayId] ?? ""
        showQuietSaved = false
        showPhraseSaved = false
    }

    private func saveQuiet() {
        let t = String(quietText.prefix(500))
        let trimmed = t.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return }
        lifestyle.setQuietLines(t, forDay: dayId)
        lifestyle.registerActivity()
        withAnimation { showQuietSaved = true }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { showQuietSaved = false }
        }
    }

    private func savePhrase() {
        let t = String(linePhrase.prefix(200).trimmingCharacters(in: .whitespacesAndNewlines))
        if t.isEmpty { return }
        lifestyle.setOnePhrase(t, forDay: dayId)
        lifestyle.registerActivity()
        withAnimation { showPhraseSaved = true }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { showPhraseSaved = false }
        }
    }
}

// MARK: - Soft prompts (read-only, local)

private enum MomentDetailExtras {
    static let hints: [[String]] = [
        [
            "Sip something warm before you answer, if the day allows.",
            "A single honest sentence is enough; polish can come later."
        ],
        [
            "Noise can be a screen, a room, or a plan that never stops moving.",
            "You can set a 10-minute timer and treat it like a small boundary."
        ],
        [
            "Curiosity with limits still counts as learning—think one step, not a syllabus.",
            "The aim is to stay in contact with the question, not to win it today."
        ],
        [
            "A boundary with warmth often lands better than the clever version of strict.",
            "Name it once in plain words; you are allowed to adjust the stretch."
        ]
    ]
}

struct MomentDetailView: View {
    let index: Int
    let text: String
    let totalPrompts: Int

    @State private var reveal: Bool = false

    private var numberLabel: String { "\(index + 1)" }
    private var totalLabel: String { "\(max(1, totalPrompts))" }

    var body: some View {
        ZStack(alignment: .top) {
            AppRootBackgroundView()
                .ignoresSafeArea()
            watermarkIndex
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    topMeta
                    mainPromptCard
                    if !currentHints.isEmpty { gentleIdeas }
                    closingStrip
                }
                .frame(maxWidth: 560, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
                .padding(.horizontal, 18)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Soft focus")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                reveal = true
            }
        }
    }

    private var watermarkIndex: some View {
        HStack {
            Spacer()
            Text(numberLabel)
                .font(.system(size: 140, weight: .ultraLight, design: .rounded))
                .foregroundStyle(Color.appPrimary.opacity(0.12))
                .offset(x: 0, y: 40)
                .accessibilityHidden(true)
        }
    }

    private var topMeta: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "sparkle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                Text("Prompt \(numberLabel) of \(totalLabel)")
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                Capsule()
                    .fill(Color.appSurface.opacity(0.95))
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 2)
            }
            .foregroundStyle(Color.appTextPrimary)
            Spacer(minLength: 0)
        }
        .opacity(reveal ? 1 : 0.4)
        .offset(y: reveal ? 0 : 6)
    }

    private var mainPromptCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary, Color.appPrimary.opacity(0.25)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 56)
            Text(text)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .appFloatCard(cornerRadius: 20, elevated: true)
        .offset(y: reveal ? 0 : 12)
        .opacity(reveal ? 1 : 0.15)
    }

    private var currentHints: [String] {
        guard index >= 0, index < MomentDetailExtras.hints.count else { return [] }
        return MomentDetailExtras.hints[index]
    }

    @ViewBuilder
    private var gentleIdeas: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.min")
                    .foregroundStyle(Color.appPrimary)
                Text("If you are stuck, borrow a thread")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            ForEach(Array(currentHints.enumerated()), id: \.offset) { _, s in
                HStack(alignment: .top, spacing: 8) {
                    Text("·")
                        .foregroundStyle(Color.appTextSecondary)
                    Text(s)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineSpacing(2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .appFloatCard(cornerRadius: 16, elevated: false)
    }

    private var closingStrip: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "hand.raised.fill")
                .foregroundStyle(Color.appTextSecondary)
            VStack(alignment: .leading, spacing: 4) {
                Text("No check-in required here. Stay as long as it still feels like care, not homework.")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineSpacing(2)
            }
        }
    }
}
