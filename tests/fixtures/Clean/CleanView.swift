// Correct iPhone Duo code. The audit must report nothing in this folder. CI enforces this.
import SwiftUI
import UIKit

struct CleanView: View {
    let columns = [GridItem(.adaptive(minimum: 160))]
    let fourColumns = Array(repeating: GridItem(.flexible()), count: 4)
    let evenColumns = [GridItem(.flexible()), GridItem(.flexible())]
    let retries = Array(repeating: 0, count: 3)
    let ratio = 0.375

    var body: some View {
        NavigationSplitView {
            List { Text("Inbox") }
        } detail: {
            VStack {
                HStack { Text("Title"); Spacer(); Text("Date") }
                Image(systemName: "photo").frame(width: 120, height: 120)
                Text("Body").frame(maxWidth: 600)
            }
            .padding(.top, 48)
            .background(Color.blue.ignoresSafeArea(edges: .bottom))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack { Text("Mail"); Spacer(); Image(systemName: "star") }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    Button { } label: { Label("Compose", systemImage: "square.and.pencil") }
                }
            }
        }
    }
}

final class CleanViewController: UIViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = view.bounds.inset(by: view.safeAreaInsets)
        let banner = UIView(frame: CGRect(x: 0, y: 0, width: 1390, height: 20))
        banner.frame.size.width = bounds.width
        let compose = UIBarButtonItem(title: "Compose", image: UIImage(systemName: "square.and.pencil"), primaryAction: nil, menu: nil)
        navigationItem.trailingItemGroups = [UIBarButtonItemGroup(barButtonItems: [compose], representativeItem: nil)]
        if traitCollection.horizontalSizeClass == .regular { banner.isHidden = false }
    }
}
