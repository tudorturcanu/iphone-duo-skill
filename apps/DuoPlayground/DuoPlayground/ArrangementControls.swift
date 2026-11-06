import SwiftUI

struct ArrangementControls: View {
    @Binding var value: Double
    let useOverlay: Bool
    @Environment(\.overlayArrangementZIndex) private var overlayIndex

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Controls", systemImage: "slider.horizontal.3").font(.headline)
            LabeledContent("Readout value") {
                Text(value / 100, format: .percent.precision(.fractionLength(0)))
                    .monospacedDigit()
            }
            HStack {
                Button("Decrease value", systemImage: "minus.circle") { value = max(0, value - 10) }
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
                    .disabled(value <= 0)
                Slider(value: $value, in: 0...100) { Text("Readout value") }
                Button("Increase value", systemImage: "plus.circle") { value = min(100, value + 10) }
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
                    .disabled(value >= 100)
            }
            Text(useOverlay ? "Overlay z-index: \(overlayIndex)" : "Split arrangement · automatic axes")
                .font(.caption.monospaced()).foregroundStyle(.secondary)
            if !useOverlay || overlayIndex <= 0 {
                Text("This is a native arrangement container. It decides how both views fit; there is no hinge-angle layout switch here.")
                    .font(.callout).foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .background(.regularMaterial, in: .rect(cornerRadius: 24))
        .padding()
    }
}
