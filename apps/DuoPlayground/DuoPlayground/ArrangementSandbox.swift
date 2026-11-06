import SwiftUI

struct ArrangementSandbox: View {
    @Bindable var model: LabModel
    @Environment(\.dismiss) private var dismiss
    @State private var useOverlay = false
    @State private var value = 35.0

    var body: some View {
        NavigationStack {
            Group {
                if useOverlay {
                    arrangement.arrangementViewStyle(.overlay)
                } else {
                    arrangement.arrangementViewStyle(.split)
                }
            }
            .navigationTitle("Arrangement sandbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") { dismiss() }
                }
                ToolbarItem(placement: .bottomBar) {
                    Toggle("Overlay arrangement", isOn: $useOverlay)
                }
            }
            .onChange(of: useOverlay, initial: true) { _, overlay in
                model.arrangementStyles.insert(overlay ? "Overlay" : "Split")
                model.log("Sandbox: actual ArrangementView using \(overlay ? "overlay" : "split") style.")
                if model.arrangementStyles.count == 2 {
                    model.complete(2, evidence: "both ArrangementView styles tried in native sandbox")
                }
            }
        }
    }

    private var arrangement: some View {
        ArrangementView {
            ArrangementControls(value: $value, useOverlay: useOverlay)
        } secondary: {
            VStack(spacing: 18) {
                Image(systemName: "sun.max.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.mint)
                    .accessibilityHidden(true)
                Text(value / 100, format: .percent.precision(.fractionLength(0)))
                    .font(.system(.largeTitle, design: .rounded).bold())
                    .contentTransition(.numericText())
                Text("A readout and its controls").font(.headline)
                Text("Flat: compare split and overlay.\nPartially folded: watch the system separate them around the fold.")
                    .font(.callout).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.mint.opacity(0.08))
        }
    }
}
