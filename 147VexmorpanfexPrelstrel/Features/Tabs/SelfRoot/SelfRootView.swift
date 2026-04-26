import SwiftUI
import StoreKit
import UIKit

struct SelfRootView: View {
    @EnvironmentObject private var life: LifestyleData
    @State private var showIntro: Bool = false

    private var activityCols: [GridItem] { [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                introHero
                headlineStats
                sectionLabel("By activity", "Lightly counted on this device only")
                activityStrip
                sectionLabel("Short views", "Read-only, no new goals")
                shortViews
                sectionLabel("Milestones", "Unlocked on real progress—no ads, no paywall")
                milestoneBlock
            }
            .appScreenPadding()
            .padding(.vertical, 8)
        }
        .appRootScrollBackground()
        .navigationTitle("Self")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            NavigationLink { SettingsView() } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(Color.appPrimary)
                    .frame(minWidth: 44, minHeight: 44)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                showIntro = true
            }
        }
    }

    private var introHero: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("You, on this device")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("A quiet summary of the pace you are keeping here—no compare panel, no public name.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineSpacing(2)
            }
            Spacer(minLength: 8)
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.4), Color.appPrimary.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "person.crop.circle")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .frame(width: 58, height: 58)
            .accessibilityHidden(true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appFloatCard(cornerRadius: 20, elevated: true)
        .offset(y: showIntro ? 0 : 10)
        .opacity(showIntro ? 1 : 0.3)
    }

    private var headlineStats: some View {
        HStack(alignment: .top, spacing: 12) {
            bigBlock(
                icon: "star.leadinghalf.filled",
                value: "\(life.totalStarCount)",
                label: "Stars collected"
            )
            bigBlock(
                icon: "flame.fill",
                value: "\(life.extra.dayStreak)",
                label: "Active-day streak"
            )
        }
        .padding(.top, 20)
    }

    private var activityStrip: some View {
        LazyVGrid(columns: activityCols, alignment: .center, spacing: 10) {
            tinyStat("figure.yoga", "\(life.wellnessState.completedCount)", "Wellness")
            tinyStat("text.book.closed", "\(life.creativeState.sessionCount)", "Creative")
            tinyStat("person.3", "\(life.connectionState.weaveSessionsCount)", "Weave")
        }
        .padding(.top, 8)
    }

    private var shortViews: some View {
        VStack(alignment: .leading, spacing: 10) {
            navRow(
                icon: "calendar.badge.clock",
                t: "This week",
                sub: "Short counts, no chart wall"
            ) { WeeklySummaryView() }
            navRow(
                icon: "tray.full",
                t: "Satisfied days",
                sub: "Past creative and weave (read-only)"
            ) { ActivityArchiveView() }
        }
    }

    @ViewBuilder
    private var milestoneBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            if life.hasStreak7Badge { milestone("figure.walk", "Seven-day run", "Seven days in a row with any action in this app.") }
            if life.hasCreative20Badge { milestone("text.page.fill", "Twenty runs", "Twenty full creative sprints, saved on device.") }
            if life.hasWeave4WeekBadge { milestone("calendar", "Four Weave weeks", "Four ISO weeks in a row with at least one Weave each week.") }
            if life.habitHeroUnlocked { milestone("heart.fill", "Habit Hero", "Six wellness rounds, steady and kind.") }
            if life.creativeMavenUnlocked { milestone("sparkles", "Creative Maven", "Four high-focus creative passes, clean runs.") }
            if life.weaveSageUnlocked { milestone("person.2.circle", "Weave Guide", "A week of connection that matched the pace you set.") }
            if !milestoneUnlocked { milestonePlaceholder }
        }
    }

    private var milestoneUnlocked: Bool {
        life.hasStreak7Badge
            || life.hasCreative20Badge
            || life.hasWeave4WeekBadge
            || life.habitHeroUnlocked
            || life.creativeMavenUnlocked
            || life.weaveSageUnlocked
    }

    private var milestonePlaceholder: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "ellipsis")
                .foregroundStyle(Color.appTextSecondary)
            Text("Nothing to pin yet. Keep a soft rhythm—this space fills in from real work, not from streak anxiety.")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionLabel(_ t: String, _ sub: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.appPrimary)
                    .frame(width: 3, height: 16)
                Text(t)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
            }
            Text(sub)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 22)
    }

    private func bigBlock(icon: String, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(Color.appPrimary)
                Spacer()
            }
            Text(value)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .appFloatCard(cornerRadius: 18, elevated: true)
    }

    private func tinyStat(_ symbol: String, _ v: String, _ t: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(Color.appPrimary)
            Text(v)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text(t)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 96)
        .appFloatCard(cornerRadius: 14, elevated: false)
    }

    @ViewBuilder
    private func navRow<Dest: View>(icon: String, t: String, sub: String, @ViewBuilder dest: () -> Dest) -> some View {
        NavigationLink { dest() } label: {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.appPrimary.opacity(0.2))
                    Image(systemName: icon)
                        .font(.title2)
                }
                .frame(width: 50, height: 50)
                VStack(alignment: .leading, spacing: 3) {
                    Text(t)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(sub)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(14)
            .appFloatCard(cornerRadius: 16, elevated: true)
        }
        .buttonStyle(.plain)
    }

    private func milestone(_ sym: String, _ title: String, _ sub: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.3), Color.appPrimary.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: sym)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(sub)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appFloatCard(cornerRadius: 16, elevated: true)
    }
}

struct SettingsView: View {
    @EnvironmentObject private var data: LifestyleData
    @State private var showReset: Bool = false
    @State private var showAlert: Bool = false
    @State private var notifOn: Bool = false
    @State private var notifTime: Date = Date()
    @State private var notifDenied: Bool = false
    @State private var notifUIBoot: Bool = true

    var body: some View {
        List {
            Section(footer: Text("Reminders are local, soft-time only. We never read your calendar or use motion.")) {
                Toggle("Gentle daily reminder", isOn: $notifOn)
                    .tint(.appPrimary)
                    .onChange(of: notifOn) { _, new in
                        if notifUIBoot { return }
                        if new {
                            Task {
                                let ok = await LocalNotificationService.requestAuthorization()
                                await MainActor.run {
                                    if ok {
                                        let c = timeParts(from: notifTime)
                                        data.setReminder(true, hour: c.h, minute: c.m)
                                        LocalNotificationService.reschedule(using: data)
                                    } else {
                                        notifOn = false
                                        notifDenied = true
                                    }
                                }
                            }
                        } else {
                            let c = timeParts(from: notifTime)
                            data.setReminder(false, hour: c.h, minute: c.m)
                            LocalNotificationService.reschedule(using: data)
                        }
                    }
                if notifOn {
                    DatePicker(
                        "Soft time (today’s clock)",
                        selection: $notifTime,
                        displayedComponents: .hourAndMinute
                    )
                    .tint(.appPrimary)
                    .onChange(of: notifTime) { _, _ in
                        guard notifOn else { return }
                        let c = timeParts(from: notifTime)
                        data.setReminder(true, hour: c.h, minute: c.m)
                        LocalNotificationService.reschedule(using: data)
                    }
                }
            }
            Section(footer: Text("Reset clears on-device data for this app on this device.")) {
                HStack {
                    Text("Stars collected")
                    Spacer()
                    Text("\(data.totalStarCount)").appPrimaryLineStyle()
                }
                HStack {
                    Text("Wellness rounds")
                    Spacer()
                    Text("\(data.wellnessState.completedCount)").appPrimaryLineStyle()
                }
                HStack {
                    Text("Creative runs")
                    Spacer()
                    Text("\(data.creativeState.sessionCount)").appPrimaryLineStyle()
                }
                HStack {
                    Text("Weave records")
                    Spacer()
                    Text("\(data.connectionState.weaveSessionsCount)").appPrimaryLineStyle()
                }
            }
            Section {
                Button { rateApp() } label: {
                    HStack {
                        Text("Rate us")
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: "star")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .buttonStyle(.borderless)
                Button { AppExternalURL.privacyPolicy.openInBrowser() } label: {
                    HStack {
                        Text("Privacy")
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .buttonStyle(.borderless)
                Button { AppExternalURL.termsOfService.openInBrowser() } label: {
                    HStack {
                        Text("Terms")
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .buttonStyle(.borderless)
            } header: {
                Text("App")
            }
            Section {
                Button {
                    showReset = true
                } label: {
                    Text("Reset all progress")
                        .foregroundStyle(Color.appPrimary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .appRootScrollBackground()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: syncNotificationUI)
        .onReceive(NotificationCenter.default.publisher(for: .lifestyleDataDidRefresh)) { _ in
            syncNotificationUI()
            withAnimation { }
        }
        .confirmationDialog(
            "Reset on-device data?",
            isPresented: $showReset
        ) {
            Button("Reset", role: .destructive) {
                data.resetAllProgress()
                showAlert = true
            }
        }
        .alert("Progress cleared", isPresented: $showAlert) { Button("OK", role: .cancel) { } } message: {
            Text("Your on-device data was cleared.")
        }
        .alert("Notifications are off in system settings. You can allow them in Settings, then return here.",
               isPresented: $notifDenied) { Button("OK", role: .cancel) { } } message: { }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func timeParts(from date: Date) -> (h: Int, m: Int) {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (c.hour ?? 9, c.minute ?? 0)
    }

    private func syncNotificationUI() {
        notifUIBoot = true
        notifOn = data.extra.reminderEnabled
        var c = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: Date()
        )
        c.hour = data.extra.reminderHour
        c.minute = data.extra.reminderMinute
        if let t = Calendar.current.date(from: c) {
            notifTime = t
        }
        DispatchQueue.main.async { notifUIBoot = false }
    }
}
