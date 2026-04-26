import SwiftUI

// MARK: - Full-screen backdrops (tabs, lists, modals)

struct AppRootBackgroundView: View {
    var body: some View {
        ZStack {
            Color.appBackground
            LinearGradient(
                colors: [
                    Color.appPrimary.opacity(0.16),
                    Color.appBackground
                ],
                startPoint: .topLeading,
                endPoint: UnitPoint(x: 0.5, y: 0.42)
            )
            LinearGradient(
                colors: [Color.appPrimary.opacity(0.05), .clear],
                startPoint: .bottom,
                endPoint: .center
            )
            RadialGradient(
                colors: [Color.appPrimary.opacity(0.14), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 340
            )
            RadialGradient(
                colors: [Color.appPrimary.opacity(0.07), .clear],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 280
            )
        }
    }
}

// MARK: - Branded fills for cards and chrome

enum AppFill {
    static var card: LinearGradient {
        LinearGradient(
            colors: [Color.appSurface, Color.appSurface.opacity(0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardElevated: LinearGradient {
        LinearGradient(
            colors: [Color.appSurface, Color.appSurface.opacity(0.68)],
            startPoint: .top,
            endPoint: .bottomTrailing
        )
    }

    static var buttonPrimary: LinearGradient {
        LinearGradient(
            colors: [Color.appPrimary, Color.appPrimary.opacity(0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    /// Full-screen background for main flows (scroll content sits on top).
    /// Safe area is respected for **content**; only the gradient backdrops the full screen.
    func appRootScrollBackground() -> some View {
        self.background {
            AppRootBackgroundView()
                .ignoresSafeArea()
        }
    }

    /// Rounded “floating” surface: gradient, soft shadow, bright rim.
    func appFloatCard(
        cornerRadius: CGFloat = 16,
        elevated: Bool = true
    ) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(elevated ? AppFill.cardElevated : AppFill.card)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: .black.opacity(elevated ? 0.26 : 0.16),
                radius: elevated ? 16 : 9,
                x: 0,
                y: elevated ? 8 : 4
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.32), Color.appTextPrimary.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
    }
}

extension View {
    /// Single-line label style for titles; use for `Text` or simple labels. For `TextField`, set line limits on the call site.
    func appPrimaryLineStyle() -> some View {
        self
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}

struct AppScreenPadding: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(16)
    }
}

extension View {
    func appScreenPadding() -> some View { modifier(AppScreenPadding()) }
}

/// Styled row for `List` with `insetGrouped` + `scrollContentBackground(.hidden)`.
extension View {
    func appInsetListRow() -> some View {
        listRowInsets(EdgeInsets(top: 4, leading: 18, bottom: 4, trailing: 18))
            .listRowBackground(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppFill.card)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 3)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                Color.appPrimary.opacity(0.14),
                                lineWidth: 0.4
                            )
                    }
            )
            .listRowSeparatorTint(Color.appTextSecondary.opacity(0.2))
    }
}
