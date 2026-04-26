import SwiftUI

struct ActivityArchiveView: View {
    @EnvironmentObject private var lifestyle: LifestyleData
    @State private var query: String = ""

    private var sortedDays: [String] {
        var keys = Set<String>()
        keys.formUnion(lifestyle.extra.creativeTextArchiveByDay.keys)
        keys.formUnion(lifestyle.extra.weaveTextArchiveByDay.keys)
        return Array(keys)
            .sorted { $0 > $1 }
            .filter { day in
                if query.isEmpty { return true }
                return day.contains(query)
                    || (lifestyle.extra.creativeTextArchiveByDay[day]?.joined(separator: " ").lowercased().contains(query.lowercased()) == true)
                    || weaveSnapshotText(lifestyle.extra.weaveTextArchiveByDay[day]).lowercased().contains(query.lowercased())
            }
    }

    var body: some View {
        List {
            if sortedDays.isEmpty {
                Text("No saved entries yet. Finish a creative or weave, then check back for the date.")
                    .appPrimaryLineStyle()
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .appInsetListRow()
            } else {
                ForEach(sortedDays, id: \.self) { day in
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            if let lines = lifestyle.extra.creativeTextArchiveByDay[day], !lines.isEmpty {
                                Text("Reflective writing")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.appTextSecondary)
                                ForEach(Array(lines.enumerated()), id: \.offset) { _, t in
                                    if t == "·" { Divider() }
                                    else { Text(t).appPrimaryLineStyle() }
                                }
                            }
                            if let snaps = lifestyle.extra.weaveTextArchiveByDay[day], !snaps.isEmpty {
                                Text("Connection plan")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.appTextSecondary)
                                ForEach(Array(snaps.enumerated()), id: \.offset) { i, s in
                                    if i > 0 { Divider() }
                                    Text("People")
                                        .font(.caption2)
                                        .foregroundStyle(Color.appTextSecondary)
                                    if s.people.isEmpty { Text("—") } else {
                                        ForEach(
                                            Array(s.people.enumerated()),
                                            id: \.offset
                                        ) { _, p in
                                            Text(verbatim: "• " + p)
                                        }
                                    }
                                    Text("Aim lines")
                                        .font(.caption2)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .padding(.top, 2)
                                    if s.focusLines.isEmpty { Text("—") } else {
                                        ForEach(
                                            Array(s.focusLines.enumerated()),
                                            id: \.offset
                                        ) { _, f in
                                            Text(verbatim: "• " + f)
                                        }
                                    }
                                }
                            }
                        }
                        .appInsetListRow()
                    } header: {
                        Text(heading(day: day))
                            .textCase(.none)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .appRootScrollBackground()
        .tint(.appPrimary)
        .searchable(
            text: $query,
            prompt: "Filter by yyyy-MM-dd or text"
        )
        .navigationTitle("Satisfied days")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func heading(day: String) -> String { day }

    private func weaveSnapshotText(_ snaps: [WeaveArchiveSnapshot]?) -> String {
        guard let snaps, !snaps.isEmpty else { return "" }
        return snaps
            .map { s in
                s.people.joined(separator: " ") + " " + s.focusLines.joined(separator: " ")
            }
            .joined(separator: " ")
    }
}
