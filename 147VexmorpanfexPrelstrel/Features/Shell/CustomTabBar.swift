import SwiftUI

struct CustomTabBar: View {
    @Binding var selection: MainTab

    var body: some View {
        HStack {
            ForEach(MainTab.allCases) { t in
                let on = (selection == t)
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: t.symbolName)
                    Text(t.title)
                        .appPrimaryLineStyle()
                        .font(.caption2)
                }
                .frame(minWidth: 44, minHeight: 44)
                .foregroundStyle(on ? Color.appPrimary : Color.appTextSecondary)
                .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { selection = t } }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 8, leading: 10, bottom: 6, trailing: 10))
        .background {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [Color.appSurface, Color.appSurface.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                LinearGradient(
                    colors: [Color.appPrimary.opacity(0.12), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .shadow(color: .black.opacity(0.35), radius: 20, y: -6)
        .overlay(alignment: .top) {
            LinearGradient(
                colors: [Color.appTextPrimary.opacity(0.15), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity, maxHeight: 1.5)
        }
    }
}
