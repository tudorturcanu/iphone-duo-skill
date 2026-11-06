import SwiftUI

/// Own the notebook above the views that adapt when the window changes.
@main
struct DuoNotesApp: App {
    @State private var notebook = Notebook()

    var body: some Scene {
        WindowGroup {
            NotesView(notebook: notebook)
        }
    }
}
