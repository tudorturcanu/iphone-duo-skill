import Foundation
import Observation

/// One editable note. Identity stays stable while its text changes.
@Observable
final class Note: Identifiable {
    let id: UUID
    var title: String
    var text: String

    init(id: UUID = UUID(), title: String, text: String) {
        self.id = id
        self.title = title
        self.text = text
    }
}
