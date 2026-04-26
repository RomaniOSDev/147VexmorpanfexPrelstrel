import SwiftUI

struct MainShellView: View {
    @EnvironmentObject private var shell: AppShellState

    var body: some View {
        ZStack(alignment: .top) {
            AppRootBackgroundView()
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Group {
                    switch shell.selected {
                    case .home: NavigationStack { HomeView() }
                    case .discover: NavigationStack { DiscoverView() }
                    case .moments: NavigationStack { MomentsView() }
                    case .selfSpace: NavigationStack { SelfRootView() }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                CustomTabBar(selection: $shell.selected)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}
