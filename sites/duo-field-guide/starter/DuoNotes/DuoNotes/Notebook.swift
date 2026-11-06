import Foundation
import Observation

/// Session state: folding and resizing never recreate this model.
/// Production storage is deliberately a separate concern.
@Observable
final class Notebook {
    var notes: [Note]
    var selection: Note.ID?

    init() {
        let first = Note(
            title: "Learning to adapt",
            text: "Edit this note, then fold and unfold the device. Your words should stay with you."
        )
        notes = [
            first,
            Note(title: "Room for ideas", text: "More space can reveal more of the same hierarchy.")
        ]
        selection = first.id
    }

    var selectedNote: Note? {
        notes.first { $0.id == selection }
    }

    func addNote() {
        let note = Note(title: "New note", text: "")
        notes.insert(note, at: 0)
        selection = note.id
    }
}
