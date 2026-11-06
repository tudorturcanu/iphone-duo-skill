import Foundation

struct StoredLab: Codable {
    var notes: [LabNote]
    var selectedID: UUID
    var completed: Set<Int>
}
