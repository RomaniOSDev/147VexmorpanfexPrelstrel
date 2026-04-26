import SwiftUI

struct ConnectionWeaveView: View {
    @EnvironmentObject private var lifestyle: LifestyleData
    @StateObject private var viewModel = ConnectionWeaveViewModel()
    @EnvironmentObject private var shell: AppShellState
    @Environment(\.dismiss) private var dismiss
    @State private var result: ActivityOutcome?
    @State private var weekWrap: ActivityOutcome?
    @State private var dayTarget: Int = 2

    var body: some View {
        ZStack(alignment: .top) {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("This week: \(lifestyle.connectionState.freshTouchesThisWeek) new threads")
                                .appPrimaryLineStyle()
                                .font(.subheadline)
                            Text("Goal across seven days: \(dayTarget * 7)")
                                .appPrimaryLineStyle()
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        Spacer()
                    }
                    .appInsetListRow()
                    Stepper(
                        value: $dayTarget,
                        in: 1...7,
                        step: 1
                    ) { Text("Daily people target: \(dayTarget)").appPrimaryLineStyle() }
                    .tint(.appPrimary)
                    .appInsetListRow()
                } header: {
                    weaveHeader("Rhythm and scope")
                } footer: {
                    weaveFooter("Targets help you set a light pace. The weekly result tallies on week change.")
                }

                Section {
                    if lifestyle.connectionState.people.isEmpty {
                        Text("No new names yet. Add a small note below, then return here.")
                            .appPrimaryLineStyle()
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .appInsetListRow()
                    } else {
                        ForEach(lifestyle.connectionState.people) { p in
                            HStack(alignment: .top) {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(Color.appPrimary)
                                Text(p.title)
                                    .appPrimaryLineStyle()
                            }
                            .appInsetListRow()
                        }
                    }
                } header: {
                    weaveHeader("People you can reach toward")
                }

                Section {
                    if lifestyle.connectionState.focusNotes.isEmpty {
                        Text("No small objectives yet.")
                            .appPrimaryLineStyle()
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .appInsetListRow()
                    } else {
                        ForEach(lifestyle.connectionState.focusNotes) { f in
                            HStack(alignment: .top) {
                                Image(systemName: "scope")
                                    .foregroundStyle(Color.appPrimary)
                                Text(f.title)
                                    .appPrimaryLineStyle()
                            }
                            .appInsetListRow()
                        }
                    }
                } header: {
                    weaveHeader("Aim lines for the week")
                }

                Section {
                    HStack(alignment: .top, spacing: 8) {
                        TextField("Name or role to reach to", text: $viewModel.nameDraft)
                            .appPrimaryLineStyle()
                            .textFieldStyle(.plain)
                            .foregroundStyle(Color.appTextPrimary)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.appBackground)
                            )
                            .onSubmit { commitPerson() }
                        Button {
                            commitPerson()
                        } label: {
                            Text("Add")
                                .appPrimaryLineStyle()
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.appPrimary)
                    }
                    .appInsetListRow()
                } header: {
                    weaveHeader("Add a new contact thread")
                }

                Section {
                    HStack(alignment: .top, spacing: 8) {
                        TextField("A short objective, clear and small", text: $viewModel.focusDraft)
                            .appPrimaryLineStyle()
                            .textFieldStyle(.plain)
                            .foregroundStyle(Color.appTextPrimary)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.appBackground)
                            )
                            .onSubmit { commitFocus() }
                        Button {
                            commitFocus()
                        } label: {
                            Text("Save")
                                .appPrimaryLineStyle()
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                        .tint(.appPrimary)
                    }
                    .appInsetListRow()
                } header: {
                    weaveHeader("Small objective in plain words")
                }

                Section {
                    Button {
                        commitWeave()
                    } label: {
                        Text("Complete daily weave")
                            .appPrimaryLineStyle()
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appPrimary)
                    .appInsetListRow()
                } footer: {
                    weaveFooter("You can record a weave at your pace. Weekly stars are tallied on week change.")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .appRootScrollBackground()
        .preferredColorScheme(.dark)
        .navigationTitle("Connection Weave")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            dayTarget = max(1, min(7, lifestyle.connectionState.dailyTarget))
            weekRolloverCheck()
        }
        .onChange(of: dayTarget) { t in
            var s = lifestyle.connectionState
            s.dailyTarget = t
            lifestyle.setConnectionState(s)
        }
        .fullScreenCover(item: $result) { p in
            ActivityResultView(
                outcome: p,
                onViewProgress: {
                    result = nil
                    dismiss()
                    shell.openSelf()
                },
                onRetry: { result = nil },
                onClose: { result = nil }
            )
        }
        .fullScreenCover(item: $weekWrap) { p in
            ActivityResultView(
                outcome: p,
                onViewProgress: {
                    weekWrap = nil
                    shell.openSelf()
                },
                onRetry: { weekWrap = nil },
                onClose: { weekWrap = nil }
            )
        }
    }

    private func commitPerson() {
        var s = lifestyle.connectionState
        viewModel.addPerson(viewModel.nameDraft, into: &s)
        viewModel.nameDraft = ""
        lifestyle.setConnectionState(s)
    }

    private func commitFocus() {
        var s = lifestyle.connectionState
        viewModel.addFocus(viewModel.focusDraft, into: &s)
        viewModel.focusDraft = ""
        lifestyle.setConnectionState(s)
    }

    private func weekRolloverCheck() {
        let n = lifestyle.finalizeConnectionWeekIfNeeded()
        guard n > 0 else { return }
        let st = lifestyle.connectionState
        var ach: String?
        if n == 3, st.weeksCompletedWithThreeStars >= 1 { ach = "Weave Guide" }
        weekWrap = ActivityOutcome(
            title: "Week review",
            bodyLines: [
                "Your new threads and aims align with a week-long, gentle target.",
                "The week that just finished returned \(n) star(s) based on reach, consistency, and target fit.",
            ],
            starCount: n,
            achievement: ach
        )
    }

    private func commitWeave() {
        var s = lifestyle.connectionState
        viewModel.recordWeaveSession(into: &s)
        lifestyle.setConnectionState(s)
        let day = lifestyle.currentCalendarDayId()
        lifestyle.appendWeaveSnapshot(day: day)
        lifestyle.registerWeaveCompletion()
        lifestyle.registerActivity()
        result = ActivityOutcome(
            title: "Weave",
            bodyLines: [
                "Weave recorded. Keep a kind cadence, your weekly tally is gathered when the week changes.",
            ],
            starCount: 0,
            achievement: nil
        )
    }

    private func weaveHeader(_ s: String) -> some View {
        Text(s)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.appTextSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func weaveFooter(_ s: String) -> some View {
        Text(s)
            .font(.caption)
            .foregroundStyle(Color.appTextSecondary.opacity(0.95))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

