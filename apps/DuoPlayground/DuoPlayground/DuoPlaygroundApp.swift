import SwiftUI

@main
struct DuoPlaygroundApp: App {
    @State private var model = LabModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .tint(.mint)
        }
    }
}
