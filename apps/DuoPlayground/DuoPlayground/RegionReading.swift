import SwiftUI

struct RegionReading: Identifiable, Equatable {
    let id: ReservedRegion.ID
    let kind: String
    let frame: CGRect
    let active: Bool

    init(region: ReservedRegion, kind: String) {
        id = region.id
        self.kind = kind
        frame = region.frame
        active = region.isActive
    }

    var coordinates: String {
        "x \(Int(frame.minX)), y \(Int(frame.minY)) · \(Int(frame.width)) × \(Int(frame.height)) pt"
    }
}
