import SwiftUI

struct RegionOverlay: View {
    let regions: [RegionReading]

    var body: some View {
        GeometryReader { _ in
            ForEach(regions.filter(\.active)) { region in
                Rectangle()
                    .fill((region.kind == "Division" ? Color.orange : Color.purple).opacity(0.22))
                    .border(region.kind == "Division" ? .orange : .purple, width: 2)
                    .frame(width: max(0, region.frame.width), height: max(0, region.frame.height))
                    .position(x: region.frame.midX, y: region.frame.midY)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
