import SwiftUI

/// The container chooses which columns fit. No device or orientation branches.
struct NotesView: View {
    @Bindable var notebook: Notebook

    var body: some View {
        NavigationSplitView {
            List(selection: $notebook.selection) {
                ForEach(notebook.notes) { note in
                    NavigationLink(value: note.id) {
                        Label(note.title.isEmpty ? "Untitled note" : note.title,
                              systemImage: "note.text")
                    }
                }
            }
            .navigationTitle("Fieldnotes")
            .toolbar {
                Button("New note", systemImage: "square.and.pencil", action: notebook.addNote)
            }
        } detail: {
            Group {
                if let note = notebook.selectedNote {
                    NoteEditor(note: note)
                } else {
                    ContentUnavailableView("Choose a note", systemImage: "note.text",
                                           description: Text("Select a note from the list or create one."))
                }
            }
            .toolbar {
                Button("New note", systemImage: "square.and.pencil", action: notebook.addNote)
            }
        }
    }
}
