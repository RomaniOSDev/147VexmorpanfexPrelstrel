import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var lifestyle: LifestyleData
    @EnvironmentObject private var shell: AppShellState
    @Environment(\.scenePhase) private var scenePhase
    @State private var dayToken: String = ""

    private let col = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerStrip
                LazyVGrid(columns: col, alignment: .leading, spacing: 12) {
                    metricTile(
                        icon: "flame.fill",
                        value: "\(lifestyle.extra.dayStreak)",
                        label: "Day run",
                        tint: Color.orange
                    )
                    metricTile(
                        icon: "star.leadinghalf.filled",
                        value: "\(lifestyle.totalStarCount)",
                        label: "Stars (all time)",
                        tint: Color.appPrimary
                    )
                    weekTile
                    rhythmTile
                }
                todayStrip
                quickStartBar
                secondaryLinks
            }
            .appScreenPadding()
            .padding(.vertical, 8)
        }
        .appRootScrollBackground()
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { dayToken = lifestyle.currentCalendarDayId() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { dayToken = lifestyle.currentCalendarDayId() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .lifestyleDataDidRefresh)) { _ in
            dayToken = lifestyle.currentCalendarDayId()
        }
    }

    private var headerStrip: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(hourGreeting)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(todayString)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer(minLength: 12)
            Image(systemName: "sun.horizon.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.appPrimary)
                .accessibilityHidden(true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appFloatCard(cornerRadius: 18, elevated: true)
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary, Color.appPrimary.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4, height: 44)
                .padding(14)
        }
    }

    private var weekTile: some View {
        NavigationLink {
            WeeklySummaryView()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Label("This week", systemImage: "calendar.badge.clock")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(lifestyle.extra.starsEarnedInIsoWeek)")
                        .font(.title.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("stars here")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Text("\(lifestyle.extra.weekActivityDayKeys.count) active day(s) · week \(lifestyle.currentWeekId())")
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
            .padding(14)
            .appFloatCard(cornerRadius: 16, elevated: true)
        }
        .buttonStyle(.plain)
    }

    private var rhythmTile: some View {
        Button {
            shell.openSelf()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Label("Your space", systemImage: "person.crop.circle.badge.checkmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                Text("Badges, long counts, and saved days.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Open Self")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
            .padding(14)
            .appFloatCard(cornerRadius: 16, elevated: true)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var todayStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            phraseCard
            microRow
        }
    }

    private var phraseCard: some View {
        let phrase = lifestyle.extra.onePhraseByDay[dayToken] ?? ""
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("In one line")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button {
                    shell.openMoments()
                } label: {
                    Text("Open Moments")
                        .font(.caption.weight(.semibold))
                }
                .tint(.appPrimary)
            }
            if phrase.isEmpty {
                Text("A single line for today, saved on device. Tap Moments to add one.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            } else {
                Text(phrase)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(3)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appFloatCard(cornerRadius: 16, elevated: true)
    }

    private var microRow: some View {
        let day = lifestyle.currentCalendarDayId()
        let pool = MicroChallengeProvider.pool
        let idx = lifestyle.currentMicroIndex(forDay: day)
        let c = (idx >= 0 && idx < pool.count) ? pool[idx] : pool.first ?? ""
        let done = lifestyle.extra.microDoneByDay[day] == true
        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: "scope")
                .font(.title3)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 28, alignment: .top)
            VStack(alignment: .leading, spacing: 6) {
                Text("One small move")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                Text(c)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if done {
                    Label("Done for today", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                } else {
                    Button {
                        lifestyle.setMicroDone(true, day: day)
                        lifestyle.registerActivity()
                    } label: {
                        Text("Mark done")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appPrimary)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appFloatCard(cornerRadius: 16, elevated: true)
    }

    private var quickStartBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Begin something small")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            HStack(spacing: 10) {
                startLink(t: "Wellness", icon: "figure.yoga") { WellnessVibesView() }
                startLink(t: "Creative", icon: "text.book.closed") {
                    CreativeWisdomView(dayId: lifestyle.currentCalendarDayId())
                }
                startLink(t: "Weave", icon: "person.3") { ConnectionWeaveView() }
            }
        }
    }

    @ViewBuilder
    private func startLink<Destination: View>(
        t: String,
        icon: String,
        @ViewBuilder dest: () -> Destination
    ) -> some View {
        NavigationLink {
            dest()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(t)
                    .font(.caption2.weight(.semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 76)
            .padding(.vertical, 8)
            .foregroundStyle(Color.appTextPrimary)
            .appFloatCard(cornerRadius: 14, elevated: false)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var secondaryLinks: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink {
                ActivitySelectionView()
            } label: {
                linkRow("All activities", "Pick a track with a calmer start", "chevron.right")
            }
            .buttonStyle(.plain)
            NavigationLink {
                ActivityArchiveView()
            } label: {
                linkRow("Satisfied days archive", "Read-only log of past creative and weave", "tray.full")
            }
            .buttonStyle(.plain)
        }
    }

    private func linkRow(
        _ title: String,
        _ sub: String,
        _ system: String
    ) -> some View {
        HStack(alignment: .center, spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.appPrimary)
                .frame(width: 3, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(sub)
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
            Image(systemName: system)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(14)
        .appFloatCard(cornerRadius: 16, elevated: true)
    }

    private func metricTile(
        icon: String,
        value: String,
        label: String,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(tint)
                Spacer()
            }
            Text(value)
                .font(.title.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
        .padding(14)
        .appFloatCard(cornerRadius: 16, elevated: true)
    }

    private var hourGreeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 5 || h >= 22 { return "Hello" }
        if h < 12 { return "Good morning" }
        if h < 17 { return "Good afternoon" }
        return "Good evening"
    }

    private var todayString: String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: Date())
    }
}

#Preview {
    HomeView()
        .environmentObject(LifestyleData())
        .environmentObject(AppShellState())
}
