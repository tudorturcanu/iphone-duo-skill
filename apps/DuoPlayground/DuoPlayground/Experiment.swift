import Foundation

enum Experiment: Int, CaseIterable, Identifiable {
    case continuity, regions, arrangements, toolbars, review
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .continuity: "Resize without restarting"
        case .regions: "See the reserved regions"
        case .arrangements: "Let the container arrange"
        case .toolbars: "Follow the system controls"
        case .review: "Make the developer decision"
        }
    }
    var symbol: String {
        switch self {
        case .continuity: "arrow.up.left.and.arrow.down.right"
        case .regions: "viewfinder"
        case .arrangements: "rectangle.2.swap"
        case .toolbars: "sidebar.left"
        case .review: "checkmark.seal"
        }
    }
    var instructions: String {
        switch self {
        case .continuity: "1. Open Workbench and edit the note.\n2. Use Closed, Open, and Rotate Right in Device Hub.\n3. Check that your words and selected note remain.\n4. In Inspect, turn on the fixed-width canvas and close the device. Turn it off to fix the clipping."
        case .regions: "1. In Workbench, enable Region guides.\n2. Select Partially Open in Device Hub.\n3. Read the active division frame in Inspect.\n4. Open the device fully and compare the inactive region.\n\nOcclusion readings only appear when the system supplies them. This app does not activate a camera."
        case .arrangements: "Open the arrangement sandbox below. Compare Split and Overlay while flat, then Partially Open. Rotate to try a horizontal fold. The actual ArrangementView chooses where the panes fit."
        case .toolbars: "1. Observe New note and Region guides in Workbench.\n2. Compare the outer display and inner display.\n3. Rotate the inner display to portrait.\n4. Look for a toolbarVerticalEdge change in the trace.\n\nThe app declares labeled actions. The system chooses placement and overflow."
        case .review: "Your editor loses its draft when the display changes. A custom button also overlaps the fold. Which implementation addresses both problems?"
        }
    }
    var code: String {
        switch self {
        case .continuity: "@State private var model = LabModel()\n\n// Stable owner above the resizing layout.\nWindowGroup {\n    RootView(model: model)\n}\n\n// Avoid sizing content from UIScreen.main."
        case .regions: "GeometryReader { proxy in\n    let folds = proxy.reservedRegions(\n        kind: .division,\n        options: .includeInactive\n    )\n    let cameras = proxy.reservedRegions(\n        kind: .occlusion\n    )\n    // Frames are in this proxy’s coordinates.\n    // Keep custom targets clear of active regions.\n}"
        case .arrangements: "NavigationStack {\n    ArrangementView {\n        ReadoutView()\n    } secondary: {\n        ControlsView()\n    }\n    .arrangementViewStyle(.overlay)\n}\n\n// Use .split for peers.\n// Keep navigation outside the arrangement."
        case .toolbars: "NavigationStack {\n    EditorView()\n        .toolbar {\n            ToolbarItemGroup(placement: .bottomBar) {\n                Button(\"New note\",\n                    systemImage: \"square.and.pencil\",\n                    action: addNote)\n            }\n        }\n}\n\n@Environment(\\.toolbarVerticalEdge)\nprivate var edge"
        case .review: "// 1. Own editing state above adaptive views.\n// 2. Size from the view’s available geometry.\n// 3. Prefer system navigation and arrangements.\n// 4. Query regions for custom controls.\n// 5. Test fold changes even without a resize."
        }
    }
    var evidence: String {
        switch self {
        case .continuity: "Verified when the workspace resizes after a note edit."
        case .regions: "Verified when guides are on and the system reports an active division."
        case .arrangements: "Verified when you try both Split and Overlay in the sandbox."
        case .toolbars: "Verified after the workspace reports two different toolbar edge values."
        case .review: "Verified when you choose the implementation below."
        }
    }
}
