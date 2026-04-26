import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var lifestyle: LifestyleData
    @State private var page = 0

    var body: some View {
        ZStack {
            AppRootBackgroundView()
                .ignoresSafeArea()
            VStack(spacing: 0) {
                OnboardingPageIndicator(current: page + 1, total: 3)
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                TabView(selection: $page) {
                    OnboardingPageMindset(onContinue: { goNext() })
                        .tag(0)
                    OnboardingPagePathways(onContinue: { goNext() })
                        .tag(1)
                    OnboardingPageSpiral(onComplete: { finish() })
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private func goNext() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            page = min(2, page + 1)
        }
    }

    private func finish() {
        lifestyle.hasSeenOnboarding = true
        lifestyle.postRefresh()
    }
}

// MARK: - Page chrome

private struct OnboardingPageIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Text("Step")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                Text("\(current) of \(total)")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color.appTextPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                Capsule()
                    .fill(AppFill.card)
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Shared layout
/// Scroll: hero + copy. Footer (CTA) stays **outside** the scroll, pinned to the bottom of
/// the page so it does not ride up when `TabView` or safe-area geometry changes.
private struct OnboardingPageScaffold<Content: View, Footer: View>: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var footer: () -> Footer

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    content()
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .appScreenPadding()
                .padding(.top, 4)
                .padding(.bottom, 8)
            }
            Spacer(minLength: 0)
            footer()
                .appScreenPadding()
                .padding(.top, 8)
                .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Primary CTA (matches app “depth” style)

@ViewBuilder
private func OnboardingMainButton(
    _ title: String,
    action: @escaping () -> Void
) -> some View {
    Button(action: action) {
        Text(title)
            .font(.headline)
            .foregroundStyle(Color.appBackground)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppFill.buttonPrimary)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    .buttonStyle(.plain)
    .shadow(color: Color.appPrimary.opacity(0.42), radius: 18, x: 0, y: 8)
}

// MARK: - Page 1

private struct OnboardingPageMindset: View {
    var onContinue: () -> Void
    @State private var turn: Double = 0
    @State private var wobble: CGFloat = 0
    @State private var appear: Bool = false

    var body: some View {
        OnboardingPageScaffold {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    RadialGradient(
                        colors: [Color.appPrimary.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Trapezoid()
                        .fill(
                            LinearGradient(
                                colors: [Color.appAccent, Color.appAccent.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 44)
                        .rotation3DEffect(.degrees(6), axis: (x: 0, y: 0, z: 1))
                        .offset(y: wobble)
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appBackground.opacity(0.15), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appPrimary.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 88, height: 88)
                        .rotationEffect(.degrees(turn))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 210)
                .scaleEffect(appear ? 1 : 0.92, anchor: .center)
                .opacity(appear ? 1 : 0.5)
                .appFloatCard(cornerRadius: 24, elevated: true)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { appear = true }
                    withAnimation(
                        .spring(response: 0.45, dampingFraction: 0.6)
                    ) { turn = 18 }
                    withAnimation(
                        .spring(response: 0.4, dampingFraction: 0.5).repeatForever(
                            autoreverses: true
                        )
                    ) { wobble = 5 }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("A calmer first screen")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Begin the day with small, intentional nudges—enough to open a little room for focus without turning your self-worth into a to-do list.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .appFloatCard(cornerRadius: 20, elevated: false)
            }
        } footer: {
            OnboardingMainButton("Continue", action: onContinue)
        }
    }
}

// MARK: - Page 2

private struct OnboardingPagePathways: View {
    var onContinue: () -> Void
    @State private var morph: CGFloat = 0
    @State private var appear: Bool = false

    var body: some View {
        OnboardingPageScaffold {
            VStack(alignment: .leading, spacing: 20) {
                HabitPathCard(progress: morph)
                    .frame(height: 210)
                    .scaleEffect(appear ? 1 : 0.95)
                    .opacity(appear ? 1 : 0.4)
                    .onAppear {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) { appear = true }
                        withAnimation(
                            .easeInOut(duration: 0.4)
                                .delay(0.1)
                        ) { morph = 1 }
                    }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Lines, not straight jackets")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Wellness, reflection, and connection sit here as separate tracks. Pick the one that matches the hour—no streak threats on this first pass.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .appFloatCard(cornerRadius: 20, elevated: false)
            }
        } footer: {
            OnboardingMainButton("Continue", action: onContinue)
        }
    }
}

private struct HabitPathCard: View {
    var progress: CGFloat

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface, Color.appSurface.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            RadialGradient(
                                colors: [Color.appPrimary.opacity(0.1), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 140
                            )
                        )
                }
                .overlay {
                    HabitPathShape(flatness: progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appPrimary.opacity(0.45)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                        )
                }
        }
        .appFloatCard(cornerRadius: 24, elevated: true)
    }
}

private struct HabitPathShape: Shape {
    var flatness: CGFloat
    var animatableData: CGFloat { get { flatness } set { flatness = newValue } }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let y0 = h * 0.5
        let segments: [CGFloat] = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
        for (i, t) in segments.enumerated() {
            let x = 20 + t * (w - 40)
            let s: CGFloat = 26 * (1 - flatness)
            let yZig = y0 + (i % 2 == 0 ? 1.0 : -1.0) * s * 0.75
            let yLine = y0
            let y = yZig * (1 - flatness) + yLine * flatness
            let pt = CGPoint(x: x, y: y)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        return p
    }
}

private struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + 18, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - 18, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Page 3

private struct OnboardingPageSpiral: View {
    var onComplete: () -> Void
    @State private var pulse: CGFloat = 0.5
    @State private var appear: Bool = false

    var body: some View {
        OnboardingPageScaffold {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    RadialGradient(
                        colors: [Color.appPrimary.opacity(0.18), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                    SpiralView(scale: pulse)
                        .stroke(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appPrimary.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .scaleEffect(appear ? 1 : 0.9, anchor: .center)
                .opacity(appear ? 1 : 0.45)
                .onAppear {
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) { appear = true }
                    withAnimation(
                        .spring(response: 0.45, dampingFraction: 0.55)
                            .repeatForever(
                                autoreverses: true
                            )
                    ) { pulse = 1.12 }
                }
                .appFloatCard(cornerRadius: 24, elevated: true)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Local, quiet, yours")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Nothing here is a public feed. Streaks and star lines stay on the device. When you are ready, tap in—when you are done, leave. That is the whole design.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .appFloatCard(cornerRadius: 20, elevated: false)
            }
        } footer: {
            OnboardingMainButton("Get started", action: onComplete)
        }
    }
}

private struct SpiralView: Shape {
    var scale: CGFloat
    var animatableData: CGFloat { get { scale } set { scale = newValue } }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxR = min(rect.width, rect.height) * 0.45 * scale
        let steps = 160
        for t in 0..<steps {
            let a = (CGFloat(t) / CGFloat(steps - 1)) * 3 * .pi
            let r = max(4, (CGFloat(t) / CGFloat(steps - 1)) * maxR)
            let x = center.x + cos(a) * r
            let y = center.y + sin(a) * r
            if t == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
        }
        return p
    }
}
