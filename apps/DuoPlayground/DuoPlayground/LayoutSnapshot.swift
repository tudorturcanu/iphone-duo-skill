import SwiftUI

struct LayoutSnapshot: Equatable {
    var size: CGSize = .zero
    var top: CGFloat = 0
    var bottom: CGFloat = 0
    var leading: CGFloat = 0
    var trailing: CGFloat = 0
    var widthClass = "Not measured"
    var toolbar = "Not measured"
    var regions: [RegionReading] = []

    var dimensions: String { "\(Int(size.width.rounded())) × \(Int(size.height.rounded())) pt" }
    var divisions: Int { regions.filter { $0.kind == "Division" && $0.active }.count }
    var occlusions: Int { regions.filter { $0.kind == "Occlusion" && $0.active }.count }

    init() {}

    init(proxy: GeometryProxy, widthClass: UserInterfaceSizeClass?, toolbar: HorizontalEdge?) {
        size = proxy.size
        top = proxy.safeAreaInsets.top
        bottom = proxy.safeAreaInsets.bottom
        leading = proxy.safeAreaInsets.leading
        trailing = proxy.safeAreaInsets.trailing
        self.widthClass = widthClass == .compact ? "Compact" : widthClass == .regular ? "Regular" : "Unspecified"
        self.toolbar = toolbar.map { $0 == .leading ? "Leading edge" : "Trailing edge" } ?? "Horizontal / no vertical edge"
        regions = proxy.reservedRegions(kind: .division, options: .includeInactive)
            .map { RegionReading(region: $0, kind: "Division") }
        regions += proxy.reservedRegions(kind: .occlusion, options: .includeInactive)
            .map { RegionReading(region: $0, kind: "Occlusion") }
    }
}
