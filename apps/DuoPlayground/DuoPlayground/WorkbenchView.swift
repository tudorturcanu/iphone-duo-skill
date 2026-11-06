import SwiftUI

struct WorkbenchView: View {
    @Bindable var model: LabModel
    @Environment(\.horizontalSizeClass) private var widthClass
    @Environment(\.toolbarVerticalEdge) private var toolbarEdge
    @State private var showInspector = false
    @State private var showNotes = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                // Reading this revision makes a hinge-only change re-query regions,
                // even if the enclosing view does not resize.
                let _ = model.hingeRevision
                let reading = LayoutSnapshot(proxy: geometry, widthClass: widthClass, toolbar: toolbarEdge)
                ArrangementView {
                    NoteEditor(model: model)
                        .layoutPriority(1)
                } secondary: {
                    InspectorView(model: model)
                        .background(.background.secondary)
                }
                .arrangementViewStyle(.split.axes(.horizontal))
                .overlay {
                    if model.showRegions { RegionOverlay(regions: reading.regions) }
                }
                .onChange(of: reading, initial: true) { _, next in model.receive(next) }
            }
            .navigationTitle("Duo Playground")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Notes", systemImage: "list.bullet") { showNotes = true }
                }
                ToolbarItem(placement: .topBarPinnedTrailing) {
                    Button("Inspect", systemImage: "sidebar.right") { showInspector = true }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("New note", systemImage: "square.and.pencil", action: model.addNote)
                    Toggle(isOn: $model.showRegions) { Label("Region guides", systemImage: "viewfinder") }
                }
                ToolbarOverflowMenu {
                    ShareLink("Share readings", item: model.report)
                }
            }
            .sheet(isPresented: $showInspector) {
                NavigationStack {
                    InspectorView(model: model)
                        .navigationTitle("Inspector")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done", systemImage: "checkmark") { showInspector = false } } }
                }
            }
            .sheet(isPresented: $showNotes) {
                NavigationStack {
                    List(model.notes) { note in
                        Button {
                            model.selectedID = note.id
                            model.log("Selected note: \(note.title).")
                            showNotes = false
                        } label: {
                            HStack {
                                Label(note.title.isEmpty ? "Untitled" : note.title, systemImage: "note.text")
                                Spacer()
                                if model.selectedID == note.id { Image(systemName: "checkmark").accessibilityLabel("Selected") }
                            }
                        }
                    }
                    .navigationTitle("Your notes")
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done", systemImage: "checkmark") { showNotes = false } } }
                }
            }
        }
    }
}
