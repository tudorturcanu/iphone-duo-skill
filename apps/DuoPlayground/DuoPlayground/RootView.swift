import SwiftUI

struct RootView: View {
    @Bindable var model: LabModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Workbench", systemImage: "rectangle.split.2x1", value: 0) {
                WorkbenchView(model: model)
            }
            Tab("Experiments", systemImage: "testtube.2", value: 1) {
                ExperimentsView(model: model, selectedTab: $selectedTab)
            }
            Tab("Signals", systemImage: "waveform.path", value: 2) {
                NavigationStack {
                    InspectorView(model: model)
                        .navigationTitle("Live signals")
                        .toolbar { ShareLink("Share report", item: model.report) }
                }
            }
        }
        .onHingeChange { _, context in model.receiveHinge(context.hinge) }
        .onChange(of: scenePhase, initial: true) { _, phase in
            model.sceneState = phase == .active ? "Active" : phase == .inactive ? "Inactive" : "Background"
            model.log("Scene phase: \(model.sceneState).")
        }
    }
}
