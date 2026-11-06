import Foundation

struct LabNote: Identifiable, Codable {
    var id = UUID()
    var title: String
    var text: String

    static let samples = [
        LabNote(title: "Room to think", text: "Start here. Write a sentence of your own.\n\nNow close and open the Duo using Device Hub. Your words should stay exactly where you left them.\n\nThis is a native SwiftUI app. The measurements in the inspector come from this view, not a device-size table."),
        LabNote(title: "The fold is a region", text: "Safe-area insets describe edges. A division region can sit inside the view.\n\nEnable Region guides in the inspector, then partially open the device. Orange marks division regions. Purple marks camera occlusion regions returned by the system.\n\nA scrolling editor may cross the fold. Custom buttons and non-scrolling text require more care."),
        LabNote(title: "Keep the owner stable", text: "The model lives above the resizing layout.\n\nThe layout can change without creating a new task. Selection and drafts are stored in the same model, and saved locally on this simulator.\n\nTry selecting this note, editing it, and changing displays. Then inspect the event log.")
    ]
}
