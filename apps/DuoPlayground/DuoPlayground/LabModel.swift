import SwiftUI
import Observation

@MainActor @Observable
final class LabModel {
    var notes: [LabNote] { didSet { draftWasEdited = true; save() } }
    var selectedID: UUID { didSet { save() } }
    var completed: Set<Int> = [] { didSet { save() } }
    var snapshot = LayoutSnapshot()
    var events: [LabEvent] = []
    var showRegions = false
    var fixedCanvas = false
    var hingeStatus = "Waiting for a hinge update"
    var hingeDegrees: Double?
    var hingeRevision = 0
    var sceneState = "Active"
    var draftWasEdited = false
    var arrangementStyles: Set<String> = []
    private var observedToolbarEdges: Set<String> = []
    private let storageKey = "duo-playground-v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let stored = try? JSONDecoder().decode(StoredLab.self, from: data), !stored.notes.isEmpty {
            notes = stored.notes
            selectedID = stored.notes.contains(where: { $0.id == stored.selectedID }) ? stored.selectedID : stored.notes[0].id
            completed = stored.completed
        } else {
            let samples = LabNote.samples
            notes = samples
            selectedID = samples[0].id
        }
        log("Playground launched. Drafts restored locally; telemetry starts fresh.")
    }

    func save() {
        let stored = StoredLab(notes: notes, selectedID: selectedID, completed: completed)
        if let data = try? JSONEncoder().encode(stored) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func log(_ message: String) {
        events.insert(LabEvent(message: message), at: 0)
        if events.count > 60 { events.removeLast(events.count - 60) }
    }

    func complete(_ lesson: Int, evidence: String) {
        if completed.insert(lesson).inserted { log("Experiment \(lesson + 1) verified: \(evidence)") }
    }

    func receive(_ next: LayoutSnapshot) {
        let previous = snapshot
        guard next != previous else { return }
        snapshot = next
        if next.size != previous.size {
            log("Workspace \(next.dimensions) · \(next.widthClass). Selection and model retained.")
            if previous.size != .zero && draftWasEdited {
                complete(0, evidence: "workspace resized after an edit; stable model retained")
            }
        }
        if next.divisions != previous.divisions || next.occlusions != previous.occlusions {
            log("Active regions: \(next.divisions) division, \(next.occlusions) occlusion.")
        }
        if next.divisions > 0 && showRegions { complete(1, evidence: "active division returned by GeometryProxy while guides are enabled") }
        if next.toolbar != previous.toolbar {
            observedToolbarEdges.insert(next.toolbar)
            log("System toolbar: \(next.toolbar).")
            if observedToolbarEdges.count > 1 { complete(3, evidence: "toolbarVerticalEdge changed across layouts") }
        }
    }

    func receiveHinge(_ hinge: DeviceHinge?) {
        hingeRevision += 1
        guard let hinge else {
            hingeStatus = "No hinge reported"
            hingeDegrees = nil
            return
        }
        hingeDegrees = hinge.angle.degrees
        let status = hinge.status == .closed ? "Closed" : hinge.status == .partiallyOpen ? "Partially open" : hinge.status == .fullyOpen ? "Fully open" : "Unknown"
        if hingeStatus != status { hingeStatus = status; log("Hinge: \(status). Layout still uses geometry and regions.") }
    }

    func addNote() {
        let note = LabNote(title: "A new idea", text: "")
        notes.append(note)
        selectedID = note.id
        log("New note created in the stable model.")
    }

    func restartExperiments() {
        completed = []
        draftWasEdited = false
        arrangementStyles = []
        observedToolbarEdges = [snapshot.toolbar]
        log("Experiment progress restarted. Existing notes and selection retained.")
    }

    var report: String {
        "Duo Playground · native workspace readings\n\(snapshot.dimensions) · \(snapshot.widthClass)\nToolbar: \(snapshot.toolbar)\nHinge: \(hingeStatus)\nActive regions: \(snapshot.divisions) division, \(snapshot.occlusions) occlusion\nScene: \(sceneState)\n\n" + events.map { "\($0.date.formatted(date: .omitted, time: .standard)) \($0.message)" }.joined(separator: "\n")
    }
}
