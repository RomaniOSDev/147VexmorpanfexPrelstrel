import SwiftUI

struct ActivitySelectionView: View {
    @EnvironmentObject private var lifestyle: LifestyleData
    @State private var headerOn: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                hero
                howYoureDoing
                threeDoors
                footnote
            }
        }
        .appRootScrollBackground()
        .navigationTitle("Your lines")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                headerOn = true
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lines you can follow today")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text("No streak pressure on this screen. Pick one lane, stay as long as it still feels kind—then go live the rest of your day.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .appFloatCard(cornerRadius: 20, elevated: true)
        .offset(y: headerOn ? 0 : 12)
        .opacity(headerOn ? 1 : 0.4)
    }

    private var howYoureDoing: some View {
        HStack(alignment: .top, spacing: 10) {
            statPill("Wellness", "\(lifestyle.wellnessState.completedCount)", "checkmark.seal")
            statPill("Creative", "\(lifestyle.creativeState.sessionCount)", "text.book.closed")
            statPill("Weave", "\(lifestyle.connectionState.weaveSessionsCount)", "person.3")
        }
        .appScreenPadding()
    }

    private func statPill(_ t: String, _ v: String, _ sym: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: sym)
                    .font(.caption2)
                Text(t)
                    .font(.caption2)
            }
            .foregroundStyle(Color.appTextSecondary)
            Text(v)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .appFloatCard(cornerRadius: 14, elevated: false)
    }

    private var threeDoors: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.appPrimary)
                    .frame(width: 3, height: 16)
                Text("Three ways in")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .padding(.bottom, 2)

            NavigationLink {
                WellnessVibesView()
            } label: {
                lineCard(
                    big: true,
                    title: "Wellness rituals",
                    sub: "Move through a plan, end with a slow, deliberate seal.",
                    icon: "figure.yoga",
                    pill: "Body · breath · pace"
                )
            }
            .buttonStyle(.plain)

            HStack(alignment: .top, spacing: 12) {
                NavigationLink {
                    CreativeWisdomView(dayId: lifestyle.currentCalendarDayId())
                } label: {
                    lineCard(
                        big: false,
                        title: "Creative sparks",
                        sub: "Prompts that roll with the day, time-box optional.",
                        icon: "text.book.closed",
                        pill: "Write · list · notice"
                    )
                }
                .buttonStyle(.plain)
                NavigationLink {
                    ConnectionWeaveView()
                } label: {
                    lineCard(
                        big: false,
                        title: "Social connection",
                        sub: "Names, one-line aims, a weekly fit check.",
                        icon: "person.3",
                        pill: "People · week"
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .appScreenPadding()
    }

    private func lineCard(
        big: Bool,
        title: String,
        sub: String,
        icon: String,
        pill: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                if big {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.45), Color.appPrimary.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                } else {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.appPrimary.opacity(0.2))
                        Image(systemName: icon)
                            .font(.title2)
                            .padding(8)
                    }
                    .frame(height: 48)
                }
                Spacer(minLength: 0)
                Text(pill)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.appPrimary.opacity(0.18)))
                    .foregroundStyle(Color.appTextPrimary)
            }
            Text(title)
                .font(big ? .title3.weight(.semibold) : .subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
            Text(sub)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(big ? 3 : 2)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Text("Start")
                    Image(systemName: "arrow.right.circle.fill")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(big ? 18 : 12)
        .appFloatCard(cornerRadius: big ? 20 : 16, elevated: true)
    }

    private var footnote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundStyle(Color.appTextSecondary)
            Text("Everything here stays on this device. You can return to the same line tomorrow without breaking a public streak here.")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(14)
        .appFloatCard(cornerRadius: 16, elevated: false)
        .appScreenPadding()
        .padding(.bottom, 12)
    }
}

#Preview {
    NavigationStack {
        ActivitySelectionView()
    }
    .environmentObject(LifestyleData())
}
