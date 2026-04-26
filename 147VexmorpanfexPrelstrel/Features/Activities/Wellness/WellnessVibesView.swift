import SwiftUI

struct WellnessVibesView: View {
    @EnvironmentObject private var lifestyle: LifestyleData
    @StateObject private var viewModel: WellnessVibesViewModel
    @EnvironmentObject private var shell: AppShellState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedBankId: String?
    @State private var result: ActivityOutcome?
    @State private var isFinishingSession: Bool = false

    init() {
        _viewModel = StateObject(wrappedValue: WellnessVibesViewModel(baseSessions: 0))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Rhythm", selection: $viewModel.difficulty) {
                    ForEach(WellnessVibesViewModel.Difficulty.allCases) { d in
                        Text(d.title).tag(d)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity)

                Text("Tap a card below, then tap the lane where it should go, matching the order above. When every lane is filled, tap Finish below.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                orderRow

                HStack(alignment: .top, spacing: 8) {
                    ForEach(Array(viewModel.slots.enumerated()), id: \.offset) { i, s in
                        let placing = selectedBankId != nil
                        laneCell(index: i, value: s, isDropHighlighted: placing && s == nil)
                    }
                }

                Text("From the row below")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.top, 4)

                bankScroll
            }
            .appScreenPadding()
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                if viewModel.isCompleteHoldAvailable {
                    finishActionButton
                } else {
                    Text("Fill every lane to enable Finish")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.appTextSecondary.opacity(0.3))
                        )
                }
            }
            .appScreenPadding()
            .frame(maxWidth: .infinity)
            .background(Color.appBackground)
        }
        .appRootScrollBackground()
        .navigationTitle("Wellness Vibes")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.setSlotCountFromOutside(lifestyle.wellnessState.completedCount) }
        .onChange(of: viewModel.slots) { _, _ in
            viewModel.evaluateFillState()
        }
        .onChange(of: viewModel.isCompleteHoldAvailable) { _, isReady in
            if isReady { selectedBankId = nil }
        }
        .onChange(of: viewModel.difficulty) { _, _ in
            selectedBankId = nil
            viewModel.onDifficultyChange()
        }
        .onChange(of: viewModel.bank) { _, ids in
            if let s = selectedBankId, !ids.contains(s) { selectedBankId = nil }
        }
        .fullScreenCover(item: $result) { payload in
            ActivityResultView(
                outcome: payload,
                onViewProgress: {
                    isFinishingSession = false
                    result = nil
                    dismiss()
                    shell.openSelf()
                },
                onRetry: {
                    isFinishingSession = false
                    result = nil
                    viewModel.rebuildChallenges()
                },
                onClose: {
                    isFinishingSession = false
                    result = nil
                }
            )
        }
    }

    // MARK: - Lanes

    @ViewBuilder
    private func laneCell(index i: Int, value s: String?, isDropHighlighted: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.appSurface)
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            laneStrokeColor(index: i, slot: s, drop: isDropHighlighted),
                            lineWidth: selectedBankId != nil && s == nil ? 2.5 : 2
                        )
                }
            if let eid = s, let e = WellnessVibesViewModel.catalog.first(where: { $0.id == eid }) {
                VStack(spacing: 4) {
                    Image(systemName: e.systemSymbol)
                        .imageScale(.large)
                        .foregroundStyle(Color.appTextPrimary)
                    Text(e.shortLabel)
                        .appPrimaryLineStyle()
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(6)
            } else {
                Text("\(i + 1)")
                    .appPrimaryLineStyle()
                    .font(.headline)
                    .foregroundStyle(
                        isDropHighlighted ? Color.appPrimary : Color.appTextSecondary
                    )
            }
        }
        .frame(minWidth: 44, minHeight: 100)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture { handleLaneTap(index: i, current: s) }
    }

    private func laneStrokeColor(index i: Int, slot s: String?, drop: Bool) -> Color {
        if let s {
            return s == viewModel.orderedTargets[i] ? Color.appPrimary : Color.appTextSecondary.opacity(0.3)
        }
        if drop { return Color.appPrimary.opacity(0.85) }
        return Color.appTextSecondary.opacity(0.3)
    }

    private func handleLaneTap(index i: Int, current s: String?) {
        if let pick = selectedBankId {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                viewModel.moveFromBankToSlot(symbolId: pick, index: i)
            }
            selectedBankId = nil
            return
        }
        if s != nil {
            viewModel.returnToBank(slotIndex: i)
        }
    }

    /// Full-width tappable control; not stacked under the scroll so hit-testing stays reliable.
    private var finishActionButton: some View {
        Button {
            finishSession()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.appPrimary)
                Text("Finish")
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .foregroundStyle(Color.appBackground)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isFinishingSession)
    }

    private var orderRow: some View {
        HStack(alignment: .top, spacing: 8) {
            ForEach(0..<viewModel.orderedTargets.count, id: \.self) { i in
                if let t = WellnessVibesViewModel.catalog
                    .first(where: { $0.id == viewModel.orderedTargets[i] }
                    )
                {
                    HStack {
                        Text("\(i + 1).")
                        Image(systemName: t.systemSymbol)
                    }
                    .appPrimaryLineStyle()
                    .font(.caption)
                    .foregroundStyle(Color.appTextPrimary)
                }
            }
        }
    }

    private var bankScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.bankRemaining) { ex in
                    let selected = selectedBankId == ex.id
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.appSurface)
                        .frame(width: 100, height: 72)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(
                                    selected ? Color.appPrimary : Color.appTextSecondary.opacity(0.25),
                                    lineWidth: selected ? 3 : 1
                                )
                        }
                        .overlay {
                            VStack {
                                Image(systemName: ex.systemSymbol)
                                Text(ex.shortLabel)
                                    .appPrimaryLineStyle()
                                    .font(.caption2)
                            }
                            .foregroundStyle(Color.appTextPrimary)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                if selected { selectedBankId = nil } else { selectedBankId = ex.id }
                            }
                        }
                }
            }
        }
    }

    private func finishSession() {
        guard viewModel.isCompleteHoldAvailable, !isFinishingSession else { return }
        isFinishingSession = true
        let stars = min(3, max(0, viewModel.starCountForCurrentPlan))
        var s = lifestyle.wellnessState
        s.completedCount += 1
        s.lastDayMarker = lifestyle.currentCalendarDayId()
        s.lastStarReward = stars
        s.bestFullness = max(
            s.bestFullness, Double(stars) / 3.0
        )
        lifestyle.setWellnessState(s)
        lifestyle.addStars(stars)
        lifestyle.registerActivity()
        if stars >= 2 { lifestyle.recordTierUnlock(tier: 1) }
        let lines = [
            "Lanes match the plan at \(Int(viewModel.scheduleAlignmentPercent))% alignment.",
            "This round earned \(stars) star(s) for schedule fullness.",
        ]
        let showHero = s.completedCount == 6 && lifestyle.habitHeroUnlocked
        result = ActivityOutcome(
            title: "Wellness Vibes",
            bodyLines: lines,
            starCount: max(0, min(3, stars)),
            achievement: showHero ? "Habit Hero" : nil
        )
    }
}

