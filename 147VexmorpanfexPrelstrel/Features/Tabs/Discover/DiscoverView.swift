import SwiftUI

// MARK: - Local copy (no network)

private enum DiscoverCopy {
    static let quotes: [String] = [
        "A small true step beats a big vague plan you never touch.",
        "Gentle rhythm wins when your week is full of other people’s numbers.",
        "The practice is the reward—stars are just confetti you kept.",
        "Connection does not need a big speech, only one honest line.",
    ]

    static let focusChips: [String] = [
        "Five calm minutes", "One honest line", "Water first",
        "Stretch once", "Tidy one thing", "Send one check-in"
    ]
}

// MARK: - View

struct DiscoverView: View {
    @EnvironmentObject private var lifestyle: LifestyleData
    @State private var showHero: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                hero
                yourRhythm
                todaysNudge
                threeTracksLabel
                pathBento
                quoteOfDay
                focusStrip
                bigActivityCTA
            }
        }
        .appRootScrollBackground()
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                showHero = true
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Find a pace, not a race")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Pick a track, drop in for a few minutes, and leave the screen without a to-do list attached to your self-worth.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineSpacing(2)
                }
                Spacer(minLength: 8)
                heroIcons
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appFloatCard(cornerRadius: 20, elevated: true)
        .offset(y: showHero ? 0 : 20)
        .opacity(showHero ? 1 : 0.45)
    }

    private var heroIcons: some View {
        HStack(spacing: -6) {
            ForEach(0..<3, id: \.self) { i in
                ZStack {
                    Circle()
                        .fill(Color.appBackground.opacity(0.55))
                    Image(systemName: ["leaf.fill", "text.quote", "water.waves"][i])
                        .font(.headline)
                        .foregroundStyle(Color.appPrimary)
                }
                .frame(width: 44, height: 44)
            }
        }
    }

    private var yourRhythm: some View {
        HStack(spacing: 12) {
            rhythmPill(
                title: "Stars on device",
                value: "\(lifestyle.totalStarCount)",
                icon: "star.fill"
            )
            rhythmPill(
                title: "This week active",
                value: "\(lifestyle.extra.weekActivityDayKeys.count)d",
                icon: "flame"
            )
            Spacer(minLength: 0)
        }
        .appScreenPadding()
    }

    private func rhythmPill(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .appPrimaryLineStyle()
            }
            .font(.caption2)
            .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appFloatCard(cornerRadius: 14, elevated: false)
    }

    private var todaysNudge: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today’s nudge")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("One tap")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.appPrimary.opacity(0.25))
                    )
                    .foregroundStyle(Color.appTextPrimary)
            }
            nudgeContent
        }
        .appScreenPadding()
    }

    @ViewBuilder
    private var nudgeContent: some View {
        let day = lifestyle.currentCalendarDayId()
        let pool = MicroChallengeProvider.pool
        let idx = lifestyle.currentMicroIndex(forDay: day)
        let c = (idx >= 0 && idx < pool.count) ? pool[idx] : pool.first ?? ""
        let done = lifestyle.extra.microDoneByDay[day] == true
        VStack(alignment: .leading, spacing: 12) {
            Text("“\(c)”")
                .font(.body.weight(.medium))
                .foregroundStyle(Color.appTextPrimary)
                .lineSpacing(3)
            if done {
                Label("Done for today", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
            } else {
                Button {
                    lifestyle.setMicroDone(true, day: day)
                    lifestyle.registerActivity()
                } label: {
                    Text("Mark it done (gentle, no extra goals)")
                }
                .buttonStyle(.borderedProminent)
                .tint(.appPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .appFloatCard(cornerRadius: 18, elevated: true)
    }

    private var threeTracksLabel: some View {
        HStack {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color.appPrimary)
                .frame(width: 3, height: 16)
            Text("Three ways in")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
        }
        .appScreenPadding()
    }

    private var pathBento: some View {
        VStack(spacing: 12) {
            pathCardLarge(
                title: "Body & calm lane",
                sub: "Wellness: match a plan, finish with a slow seal.",
                icon: "figure.yoga",
                tint: 0.45
            ) { WellnessVibesView() }
            HStack(alignment: .top, spacing: 12) {
                pathCardSmall(
                    title: "Write & reflect",
                    sub: "Prompt deck, same-day cadence",
                    icon: "text.book.closed",
                    destination: AnyView(
                        CreativeWisdomView(dayId: lifestyle.currentCalendarDayId())
                    )
                )
                pathCardSmall(
                    title: "People & week",
                    sub: "Weave, tiny aims, no scoreboard",
                    icon: "person.3",
                    destination: AnyView(ConnectionWeaveView())
                )
            }
        }
        .appScreenPadding()
    }

    @ViewBuilder
    private func pathCardLarge<Destination: View>(
        title: String,
        sub: String,
        icon: String,
        tint: Double,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink { destination() } label: {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(tint), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundStyle(Color.appTextPrimary)
                }
                .frame(width: 64, height: 64)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(sub)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        Spacer()
                        Text("Start")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appPrimary)
                    }
                }
            }
            .padding(16)
            .appFloatCard(cornerRadius: 20, elevated: true)
        }
        .buttonStyle(.plain)
    }

    private func pathCardSmall<Destination: View>(title: String, sub: String, icon: String, destination: Destination) -> some View {
        NavigationLink { destination } label: {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.appPrimary.opacity(0.2))
                    Image(systemName: icon)
                        .font(.title2)
                        .padding(10)
                }
                .frame(height: 64)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(sub)
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .appFloatCard(cornerRadius: 16, elevated: true)
        }
        .buttonStyle(.plain)
    }

    private var quoteOfDay: some View {
        let d = lifestyle.currentCalendarDayId()
        let i = abs(d.hashValue) % max(1, DiscoverCopy.quotes.count)
        let line: String = (i < DiscoverCopy.quotes.count) ? DiscoverCopy.quotes[i] : DiscoverCopy.quotes[0]
        return HStack(alignment: .top, spacing: 10) {
            Image(systemName: "text.quote")
                .font(.title2)
                .foregroundStyle(Color.appPrimary.opacity(0.85))
            Text(line)
                .font(.subheadline.italic())
                .foregroundStyle(Color.appTextPrimary.opacity(0.95))
                .lineSpacing(2)
        }
        .appScreenPadding()
        .appFloatCard(cornerRadius: 16, elevated: false)
    }

    private var focusStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ideas that fit in a breath")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DiscoverCopy.focusChips, id: \.self) { t in
                        Text(t)
                            .font(.caption2.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background {
                                Capsule()
                                    .fill(AppFill.card)
                                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                            }
                            .foregroundStyle(Color.appTextPrimary)
                    }
                }
            }
        }
        .appScreenPadding()
    }

    private var bigActivityCTA: some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink {
                ActivitySelectionView()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("See all activity lines")
                            .font(.headline)
                        Text("Same three tracks, shown as a list if you like lists.")
                            .font(.caption)
                            .foregroundStyle(Color.appBackground.opacity(0.85))
                            .lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppFill.buttonPrimary)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.appPrimary.opacity(0.4), radius: 18, x: 0, y: 8)
            .foregroundStyle(Color.appBackground)
        }
        .appScreenPadding()
        .padding(.bottom, 8)
    }
}
