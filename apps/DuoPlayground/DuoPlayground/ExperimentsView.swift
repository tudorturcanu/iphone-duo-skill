import SwiftUI

struct ExperimentsView: View {
    @Bindable var model: LabModel
    @Binding var selectedTab: Int
    @State private var confirmRestart = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Learn by changing\nthe space.").font(.largeTitle.bold())
                        Text("Five small experiments in a real SwiftUI app.")
                            .foregroundStyle(.secondary)
                        ProgressView(value: Double(model.completed.count), total: 5)
                            .accessibilityLabel("Experiments completed")
                        Text("\(model.completed.count) of 5 verified").font(.caption.monospaced())
                    }.padding(.vertical, 12)
                }
                Section("Your experiments") {
                    ForEach(Experiment.allCases) { lesson in
                        NavigationLink(value: lesson) {
                            HStack(spacing: 14) {
                                Image(systemName: model.completed.contains(lesson.rawValue) ? "checkmark.circle.fill" : lesson.symbol)
                                    .foregroundStyle(.mint)
                                    .accessibilityLabel(model.completed.contains(lesson.rawValue) ? "Verified" : "Not yet verified")
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("0\(lesson.rawValue + 1)").font(.caption2.monospaced()).foregroundStyle(.secondary)
                                    Text(lesson.title).font(.headline)
                                }.padding(.vertical, 8)
                            }
                        }
                    }
                }
                Section {
                    Text("Use Device Hub’s pose controls to change the simulator. The app measures the result; it never pretends to change hardware from inside a view.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Experiments")
            .toolbar {
                Button("Restart progress", systemImage: "arrow.counterclockwise") { confirmRestart = true }
                    .confirmationDialog("Restart experiment progress? Your notes stay saved.", isPresented: $confirmRestart) {
                        Button("Restart progress", action: model.restartExperiments)
                    }
            }
            .navigationDestination(for: Experiment.self) { lesson in
                ExperimentDetail(lesson: lesson, model: model, selectedTab: $selectedTab)
            }
        }
    }
}
