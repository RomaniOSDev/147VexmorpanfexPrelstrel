import SwiftUI

struct ActivityOutcome: Identifiable {
    let id = UUID()
    let title: String
    let bodyLines: [String]
    let starCount: Int
    let achievement: String?
}

struct ActivityResultView: View {
    let outcome: ActivityOutcome
    var onViewProgress: () -> Void
    var onRetry: () -> Void
    var onClose: () -> Void

    @State private var visibleStars: Int = 0
    @State private var showBanner: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            AppRootBackgroundView()
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { i in
                                let lit = (i < outcome.starCount) && (i < visibleStars)
                                Image(systemName: lit ? "star.fill" : "star")
                                    .foregroundStyle(lit ? Color.appAccent : Color.appTextSecondary)
                                    .font(.title)
                                    .shadow(
                                        color: lit ? Color.appAccent : .clear,
                                        radius: 5, x: 0, y: 0
                                    )
                            }
                        }
                        Text("This session is complete")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                            .appPrimaryLineStyle()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(outcome.bodyLines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .appFloatCard(cornerRadius: 22, elevated: true)
                .appScreenPadding()
            }
            if showBanner, let t = outcome.achievement {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appSurface, Color.appSurface.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
                    .frame(height: 64)
                    .overlay(
                        HStack {
                            Text(t)
                                .appPrimaryLineStyle()
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                        }
                        .appScreenPadding()
                    )
                    .transition(
                        .move(edge: .top)
                            .combined(with: .opacity)
                    )
            }
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    Button {
                        onRetry()
                    } label: {
                        Text("Retry")
                            .appPrimaryLineStyle()
                            .font(.headline)
                            .foregroundStyle(Color.appBackground)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.appPrimary.opacity(0.8))
                            )
                    }
                    .buttonStyle(.plain)
                    Button {
                        onViewProgress()
                    } label: {
                        Text("View Progress")
                            .appPrimaryLineStyle()
                            .font(.headline)
                            .foregroundStyle(Color.appBackground)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.appPrimary)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .appScreenPadding()
            }
        }
        .onAppear {
            for i in 0..<outcome.starCount {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.15 * Double(i)
                ) { withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { visibleStars = i + 1 } }
            }
            if outcome.achievement != nil {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showBanner = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 0.3)) { showBanner = false }
                }
            }
        }
    }
}
