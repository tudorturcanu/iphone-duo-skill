import Foundation

struct LabEvent: Identifiable {
    var id = UUID()
    var date = Date()
    var message: String
}
