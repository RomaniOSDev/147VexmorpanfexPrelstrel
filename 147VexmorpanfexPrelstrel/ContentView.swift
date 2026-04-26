//
//  ContentView.swift
//  147VexmorpanfexPrelstrel
//
//  Created by Roman on 4/26/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var lifestyle = LifestyleData()
    @StateObject private var shell = AppShellState()

    var body: some View {
        Group {
            if lifestyle.hasSeenOnboarding {
                MainShellView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(lifestyle)
        .environmentObject(shell)
        .onAppear {
            // Next run loop: avoids "Publishing from within view updates" when @AppStorage / state mutates.
            Task { @MainActor in
                lifestyle.applyIsoWeekRollover()
                _ = lifestyle.finalizeConnectionWeekIfNeeded()
                LocalNotificationService.reschedule(using: lifestyle)
            }
        }
    }
}

#Preview {
    ContentView()
}
