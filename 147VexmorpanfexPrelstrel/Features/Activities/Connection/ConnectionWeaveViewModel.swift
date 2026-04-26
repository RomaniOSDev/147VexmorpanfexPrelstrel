import Foundation
import SwiftUI
import Combine

@MainActor
final class ConnectionWeaveViewModel: ObservableObject {
    @Published var nameDraft: String = ""
    @Published var focusDraft: String = ""

    func addPerson(
        _ name: String,
        into data: inout ConnectionPersistentState
    ) {
        let t = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        data.people
            .insert(ConnectionPersistentState.WeaveItem(
                id: UUID(),
                title: t,
                kind: "person"
            ), at: 0)
        data.freshTouchesThisWeek += 1
    }

    func addFocus(
        _ line: String,
        into data: inout ConnectionPersistentState
    ) {
        let t = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        data.focusNotes
            .insert(ConnectionPersistentState.WeaveItem(
                id: UUID(),
                title: t,
                kind: "note"
            ), at: 0)
    }

    func recordWeaveSession(into data: inout ConnectionPersistentState) {
        data.weaveSessionsCount += 1
    }
}
