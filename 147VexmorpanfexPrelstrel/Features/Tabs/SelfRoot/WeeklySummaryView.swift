import SwiftUI
import UIKit

struct WeeklySummaryView: View {
    @EnvironmentObject private var lifestyle: LifestyleData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 20) {
                Text("A short look at the week, without a chart wall.")
                    .appPrimaryLineStyle()
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                HStack(alignment: .top, spacing: 8) {
                    RoundedRectangle(cornerRadius: 2).fill(Color.appPrimary)
                        .frame(width: 3, height: 40)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This ISO week")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)
                        Text(ISOWeekLine())
                            .appPrimaryLineStyle()
                            .font(.title3)
                            .foregroundStyle(Color.appTextPrimary)
                    }
                }
                HStack {
                    VStack(alignment: .leading) { big("\(e.starsEarnedInIsoWeek)", "Stars in week") }
                    Spacer()
                    VStack(alignment: .trailing) { big("\(e.weekActivityDayKeys.count)", "Days with any action") }
                }
                HStack {
                    VStack(alignment: .leading) { big("\(e.thisWeekWeaveCompletions)", "Weave check-ins (week)") }
                    Spacer()
                    VStack(alignment: .trailing) { big("\(e.dayStreak)", "Active-day streak") }
                }
                }
                .padding(16)
                .appFloatCard(cornerRadius: 20, elevated: true)
                WeekSummaryCopyCard()
            }
            .appScreenPadding()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .appRootScrollBackground()
        .navigationTitle("This week")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ShareLink(
                item: lifestyle.weeklySummaryExportString(),
                subject: Text("Week note"),
                message: Text("Short summary from your local rhythm app.")
            ) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(Color.appPrimary)
            }
        }
    }

    private var e: LifestyleExtraState { lifestyle.extra }

    private func ISOWeekLine() -> String { "Ref: \(lifestyle.currentWeekId())" }

    private func big(_ v: String, _ t: String) -> some View {
        VStack(alignment: .leading) {
            Text(v)
                .appPrimaryLineStyle()
                .font(.title2.weight(.semibold))
            Text(t)
                .appPrimaryLineStyle()
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
        }
    }
}

struct WeekSummaryCopyCard: View {
    @EnvironmentObject private var lifestyle: LifestyleData
    @State private var showCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 2).fill(Color.appPrimary)
                    .frame(width: 3, height: 32)
                VStack(alignment: .leading) {
                    Text("Save this week’s note")
                        .appPrimaryLineStyle()
                        .font(.subheadline.weight(.semibold))
                    Text("You can paste into any app on this device; nothing leaves your device unless you share it yourself.")
                        .appPrimaryLineStyle()
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            HStack {
                Button {
                    UIPasteboard.general.string = lifestyle.weeklySummaryExportString()
                    withAnimation { showCopied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showCopied = false }
                } label: {
                    Text("Copy to clipboard")
                        .appPrimaryLineStyle()
                }
                .buttonStyle(.borderedProminent)
                .tint(.appPrimary)
                Spacer()
            }
            if showCopied { Text("Copied.").font(.caption).foregroundStyle(Color.appTextSecondary) }
        }
        .padding(12)
        .appFloatCard(cornerRadius: 16, elevated: true)
    }
}
