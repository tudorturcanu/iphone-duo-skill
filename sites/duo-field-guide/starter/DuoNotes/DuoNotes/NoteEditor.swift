import SwiftUI

/// Edits the selected model directly, so compact and expanded layouts agree.
struct NoteEditor: View {
    @Bindable var note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Note title", text: $note.title, axis: .vertical)
                .font(.title.bold())
                .accessibilityLabel("Note title")
            TextEditor(text: $note.text)
                .font(.body)
                .accessibilityLabel("Note text")
            Text("Session demo · relaunching resets these notes")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
    }
}
