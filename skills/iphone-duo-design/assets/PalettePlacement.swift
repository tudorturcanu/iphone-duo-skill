import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

/// Sample geometry for positioning a complete palette; this is not an Apple API.
enum PalettePlacement {
    /// Returns a palette frame inside the available bounds, avoiding every region.
    ///
    /// The palette keeps its size. If a preferred area can contain it, that area
    /// is searched first; otherwise the search uses all available bounds. Within
    /// either area, the result is nearest to the palette's original position
    /// centered in `availableBounds`. Edge contact with a reserved region is
    /// allowed, but positive-area overlap is not.
    ///
    /// - Parameters:
    ///   - paletteSize: The complete group's positive, finite size.
    ///   - availableBounds: The positive, finite rectangle available to controls.
    ///   - reservedRegions: Rectangles to avoid, in the same coordinate space.
    ///     Region margins must already be included. Empty regions are ignored;
    ///     regions extending outside the bounds are clipped for the search.
    ///   - preferredArea: An optional preference, such as below a tabletop fold.
    ///     Its intersection with the available bounds is used when it fits.
    /// - Returns: An unchanged-size frame, or `nil` if none fits or required
    ///   geometry is nonfinite. The caller must handle `nil` without dropping
    ///   actions, for example by presenting them in a system-managed toolbar.
    /// - Complexity: O(n³) for n regions; intended for a small set of regions.
    static func frame(
        for paletteSize: CGSize,
        in availableBounds: CGRect,
        avoiding reservedRegions: [CGRect],
        preferring preferredArea: CGRect? = nil
    ) -> CGRect? {
        guard paletteSize.width.isFinite, paletteSize.height.isFinite,
              paletteSize.width > 0, paletteSize.height > 0,
              hasFiniteEdges(availableBounds),
              availableBounds.width > 0, availableBounds.height > 0,
              paletteSize.width <= availableBounds.width,
              paletteSize.height <= availableBounds.height else { return nil }

        let desiredOrigin = CGPoint(
            x: availableBounds.midX - paletteSize.width / 2,
            y: availableBounds.midY - paletteSize.height / 2
        )
        var obstacles: [CGRect] = []
        for region in reservedRegions {
            if region.isNull || region.isEmpty { continue }
            guard hasFiniteEdges(region) else { return nil }
            let clipped = region.intersection(availableBounds)
            if !clipped.isNull && !clipped.isEmpty {
                obstacles.append(clipped)
            }
        }

        if let preferredArea, hasFiniteEdges(preferredArea) {
            let preferredBounds = preferredArea.intersection(availableBounds)
            if let frame = nearestFrame(
                of: paletteSize, in: preferredBounds, avoiding: obstacles,
                closestTo: desiredOrigin
            ) {
                return frame
            }
        }
        return nearestFrame(
            of: paletteSize, in: availableBounds, avoiding: obstacles,
            closestTo: desiredOrigin
        )
    }

    /// Finds the frame nearest the original origin within one search rectangle.
    private static func nearestFrame(
        of size: CGSize, in bounds: CGRect, avoiding obstacles: [CGRect],
        closestTo desired: CGPoint
    ) -> CGRect? {
        guard !bounds.isNull, !bounds.isEmpty,
              size.width <= bounds.width, size.height <= bounds.height else { return nil }

        var candidateXs = [desired.x, bounds.minX, bounds.maxX - size.width]
        var candidateYs = [desired.y, bounds.minY, bounds.maxY - size.height]
        for obstacle in obstacles {
            // A closest feasible frame either stays centered or meets an edge.
            candidateXs += [obstacle.maxX, obstacle.minX - size.width]
            candidateYs += [obstacle.maxY, obstacle.minY - size.height]
        }

        var best: CGRect?
        var bestDistance = CGFloat.infinity
        for x in candidateXs {
            for y in candidateYs {
                let origin = CGPoint(
                    x: min(max(x, bounds.minX), bounds.maxX - size.width),
                    y: min(max(y, bounds.minY), bounds.maxY - size.height)
                )
                let candidate = CGRect(origin: origin, size: size)
                guard bounds.contains(candidate),
                      obstacles.allSatisfy({ candidate.intersection($0).isEmpty }) else {
                    continue
                }
                let distance = hypot(origin.x - desired.x, origin.y - desired.y)
                if best == nil || distance < bestDistance {
                    best = candidate
                    bestDistance = distance
                }
            }
        }
        return best
    }

    /// Rejects coordinates or dimensions that cannot support finite placement.
    private static func hasFiniteEdges(_ rectangle: CGRect) -> Bool {
        rectangle.origin.x.isFinite && rectangle.origin.y.isFinite
            && rectangle.width.isFinite && rectangle.height.isFinite
            && rectangle.minX.isFinite && rectangle.maxX.isFinite
            && rectangle.minY.isFinite && rectangle.maxY.isFinite
    }
}
