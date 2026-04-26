import SwiftUI

struct CreativeWisdomView: View {
    @EnvironmentObject private var lifestyle: LifestyleData
    @StateObject private var viewModel: CreativeWisdomViewModel
    @EnvironmentObject private var shell: AppShellState
    @Environment(\.dismiss) private var dismiss
    @State private var result: ActivityOutcome?

    init(dayId: String) {
        _viewModel = StateObject(
            wrappedValue: CreativeWisdomViewModel(dayId: dayId)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Timer: \(viewModel.elapsed) s")
                    .appPrimaryLineStyle()
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
            }
            .appScreenPadding()
            .background(Color.appSurface)
            TabView {
                ForEach(0..<viewModel.pack.count, id: \.self) { c in
                    let card = viewModel.pack[c]
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(card.title)
                                .appPrimaryLineStyle()
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            ForEach(0..<card.questions.count, id: \.self) { q in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(q + 1). \(card.questions[q])")
                                        .appPrimaryLineStyle()
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appTextSecondary)
                                    textField(
                                        c: c,
                                        q: q
                                    )
                                }
                            }
                        }
                        .appScreenPadding()
                    }
                    .background(Color.appBackground)
                }
            }
            .tabViewStyle(.page)
            Text("Your entries are reflected on screen and kept local to this device.")
                .appPrimaryLineStyle()
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .appScreenPadding()
            Spacer(minLength: 0)
        }
        .appRootScrollBackground()
        .safeAreaInset(edge: .bottom) {
            submitBar
        }
        .navigationTitle("Creative Deck")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        .onChange(of: viewModel.answers) { _ in
            var st = lifestyle.creativeState
            viewModel.autosave(into: &st)
            lifestyle.setCreativeState(st)
        }
        .onChange(of: viewModel.elapsed) { _ in
            var st = lifestyle.creativeState
            st.lastJournalSeconds = max(
                st.lastJournalSeconds, viewModel.elapsed
            )
            lifestyle.setCreativeState(st)
        }
        .fullScreenCover(item: $result) { payload in
            ActivityResultView(
                outcome: payload,
                onViewProgress: {
                    result = nil
                    dismiss()
                    shell.openSelf()
                },
                onRetry: {
                    result = nil
                    viewModel.resetSession()
                },
                onClose: { result = nil }
            )
        }
    }

    private var submitBar: some View {
        Button {
            submit()
        } label: {
            Text("Submit deck")
                .appPrimaryLineStyle()
                .font(.headline)
                .foregroundStyle(Color.appBackground)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.appPrimary)
                )
        }
        .appScreenPadding()
    }

    private func textField(c: Int, q: Int) -> some View {
        TextField(
            "Type here",
            text: Binding(
                get: { viewModel.answers[c][q] },
                set: { viewModel.setAnswer(
                    card: c,
                    line: q,
                    value: $0
                ) }
            ),
            axis: .vertical
        )
        .textFieldStyle(.plain)
        .font(.subheadline)
        .lineLimit(4, reservesSpace: true)
        .minimumScaleFactor(0.7)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.appSurface)
        )
    }

    private func submit() {
        let stars = viewModel.starResult
        var s = lifestyle.creativeState
        s.sessionCount += 1
        s.lastStarReward = stars
        s.lastPackDay = lifestyle.currentCalendarDayId()
        s.lastJournalSeconds = max(
            s.lastJournalSeconds, viewModel.elapsed
        )
        if stars == 3 { s.qualityRunCount += 1 }
        lifestyle.setCreativeState(s)
        lifestyle.addStars(stars)
        if stars >= 2 { lifestyle.recordTierUnlock(tier: 2) }
        let day = lifestyle.currentCalendarDayId()
        let keepLines = viewModel.answers
            .flatMap { $0 }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        lifestyle.appendCreativeArchive(day: day, answers: keepLines)
        lifestyle.registerActivity()
        let n = viewModel.answers
            .flatMap { $0 }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count
        let lines: [String] = [
            "You answered \(n) prompts, with about \(viewModel.elapsed) seconds in this focused pass.",
        ]
        result = ActivityOutcome(
            title: "Creative deck",
            bodyLines: lines,
            starCount: min(3, max(0, stars)),
            achievement: (s.qualityRunCount == 4 && stars == 3) ? "Creative Maven" : nil
        )
    }
}
