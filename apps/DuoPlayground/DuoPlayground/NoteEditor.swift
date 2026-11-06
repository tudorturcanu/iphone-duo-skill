import SwiftUI

struct NoteEditor: View {
    @Bindable var model: LabModel
    @FocusState private var editorFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Label("NATIVE WORKSPACE", systemImage: "circle.fill")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.mint)
                    Spacer()
                    Text(model.snapshot.widthClass).font(.caption).foregroundStyle(.secondary)
                }
                if let index = model.notes.firstIndex(where: { $0.id == model.selectedID }) {
                    TextField("Note title", text: $model.notes[index].title, axis: .vertical)
                        .font(.largeTitle.bold())
                        .focused($editorFocused)
                        .accessibilityIdentifier("note-title")
                    Label("Saved on this simulator", systemImage: "checkmark.circle")
                        .font(.caption).foregroundStyle(.secondary)
                    TextEditor(text: $model.notes[index].text)
                        .font(.body)
                        .focused($editorFocused)
                        .scrollDismissesKeyboard(.interactively)
                        .scrollContentBackground(.hidden)
                        .accessibilityLabel("Note body")
                        .accessibilityIdentifier("note-body")
                }
                Divider()
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: model.fixedCanvas ? "exclamationmark.triangle" : "arrow.up.left.and.arrow.down.right")
                    Text(model.fixedCanvas ? "Fixed 680 pt canvas. Close the device to see the clipping. Disable it in Inspect." : "Change the device pose in Device Hub. The layout changes; your note stays.")
                }
                .font(.footnote)
                .foregroundStyle(model.fixedCanvas ? .orange : .secondary)
            }
            .padding(24)
            // Intentionally bad comparison, isolated from navigation and model.
            .frame(width: model.fixedCanvas ? 680 : geometry.size.width, height: geometry.size.height, alignment: .topLeading)
        }
        .clipped()
        .background(.background)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Done editing", systemImage: "checkmark") { editorFocused = false }
            }
        }
    }
}
