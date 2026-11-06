import SwiftUI

struct InspectorView: View {
    @Bindable var model: LabModel

    var body: some View {
        List {
            Section {
                Label("Read from the running app", systemImage: "dot.radiowaves.left.and.right")
                    .font(.headline)
                Text("Workspace values are measured in the Workbench’s GeometryReader. They stay at their last reading while another tab is visible.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Workspace") {
                LabeledContent("View bounds", value: model.snapshot.dimensions)
                LabeledContent("Width class", value: model.snapshot.widthClass)
                LabeledContent("Toolbar", value: model.snapshot.toolbar)
                LabeledContent("Scene", value: model.sceneState)
                LabeledContent("Hinge", value: model.hingeStatus)
                if let degrees = model.hingeDegrees {
                    LabeledContent("Angle", value: "\(Int(degrees.rounded()))° · diagnostic only")
                }
            }
            Section("Safe-area insets · pt") {
                LabeledContent("Top / bottom", value: "\(Int(model.snapshot.top)) / \(Int(model.snapshot.bottom))")
                LabeledContent("Leading / trailing", value: "\(Int(model.snapshot.leading)) / \(Int(model.snapshot.trailing))")
            }
            Section {
                Toggle("Region guides", isOn: $model.showRegions)
                    .onChange(of: model.showRegions) { _, enabled in
                        if enabled && model.snapshot.divisions > 0 { model.complete(1, evidence: "active division observed with region guides enabled") }
                    }
                if model.snapshot.regions.isEmpty {
                    Text("No reserved regions returned in this view.").foregroundStyle(.secondary)
                }
                ForEach(model.snapshot.regions) { region in
                    VStack(alignment: .leading, spacing: 5) {
                        Label("\(region.kind) · \(region.active ? "active" : "inactive")", systemImage: region.kind == "Division" ? "rectangle.split.2x1" : "camera")
                            .foregroundStyle(region.kind == "Division" ? .orange : .purple)
                        Text(region.coordinates).font(.caption.monospaced()).foregroundStyle(.secondary)
                    }
                }
            } header: { Text("Reserved regions") } footer: {
                Text("Orange: division. Purple: occlusion. Frames use workspace coordinates and include margins. A missing region is not a simulated camera or fold.")
            }
            Section {
                Toggle("Use a fixed-width canvas", isOn: $model.fixedCanvas)
                Text("Intentionally fragile: only the editor uses a fixed 680 pt width. Navigation and the stored draft remain reachable. Turn it off to restore adaptation.")
                    .font(.footnote).foregroundStyle(.secondary)
            } header: { Text("Break it, then fix it") }
            Section("Event trace · latest first") {
                ForEach(model.events) { event in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(event.date, format: .dateTime.hour().minute().second())
                            .font(.caption2.monospaced()).foregroundStyle(.secondary)
                        Text(event.message).font(.footnote)
                    }
                    .textSelection(.enabled)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
