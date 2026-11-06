import SwiftUI

struct ExperimentDetail: View {
    let lesson: Experiment
    @Bindable var model: LabModel
    @Binding var selectedTab: Int
    @State private var answerFeedback = ""
    @State private var showSandbox = false

    var body: some View {
        List {
            Section {
                Label(lesson.title, systemImage: lesson.symbol).font(.title2.bold())
                Text(lesson.instructions).lineSpacing(6)
            }
            Section {
                Label(model.completed.contains(lesson.rawValue) ? "Verified" : "Try it in the app", systemImage: model.completed.contains(lesson.rawValue) ? "checkmark.circle.fill" : "hand.tap")
                    .foregroundStyle(.mint)
                Text(lesson.evidence).font(.footnote).foregroundStyle(.secondary)
                if lesson == .arrangements {
                    Button("Open arrangement sandbox", systemImage: "rectangle.2.swap") { showSandbox = true }
                } else if lesson != .review {
                    Button("Go to Workbench", systemImage: "arrow.right") { selectedTab = 0 }
                }
            }
            if lesson == .review {
                Section("Choose an implementation") {
                    Button("Keep the model stable; use view geometry and reserved regions.") {
                        answerFeedback = "Correct. A fold changes the available layout, not the identity of the task. Custom controls must account for interior regions as well as edge insets."
                        model.complete(4, evidence: "selected stable model ownership and region-aware custom layout")
                    }
                    Button("Recreate the editor whenever the hinge crosses 90°.") {
                        answerFeedback = "That can lose the draft and does not describe a camera region or the app’s available bounds. Use geometry and regions for layout."
                    }
                    Button("Add the same extra padding on every edge.") {
                        answerFeedback = "Insets differ by edge, and a division may be in the center. Edge padding alone cannot express that region."
                    }
                    if !answerFeedback.isEmpty { Text(answerFeedback).font(.callout).accessibilityIdentifier("answer-feedback") }
                }
            }
            Section("Swift pattern · iOS 27.1 SDK") {
                Text(lesson.code)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                Text("A teaching excerpt. Open the project to edit the complete, compiled implementation.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Experiment \(lesson.rawValue + 1)")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showSandbox) { ArrangementSandbox(model: model) }
    }
}
