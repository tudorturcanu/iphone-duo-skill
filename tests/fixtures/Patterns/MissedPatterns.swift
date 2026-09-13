// Every line marked "duo-bad" must be flagged by the audit. CI enforces this.
import SwiftUI
import UIKit

struct PatternsView: View {
    let gridColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // duo-bad
    let fiveColumns = Array(repeating: GridItem(.flexible()), count: 5) // duo-bad

    var body: some View {
        LazyVGrid(columns: gridColumns) { Text("Item") }
            .frame(width: 120, height: 480) // duo-bad
            .padding(.top, 59) // duo-bad
            .padding(.bottom, 34) // duo-bad
            .ignoresSafeArea() // duo-bad
            .toolbarVisibility(.hidden, for: .tabBar) // duo-bad
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Share") {}
                    Spacer() // duo-bad
                    Button("Delete") {}
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu { Button("Print") {} } label: { Label("More", systemImage: "ellipsis.circle") } // duo-bad
                }
            }
    }
}

final class PatternsViewController: UIViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.window?.windowScene?.screen.bounds.width ?? 0 // duo-bad
        let height = UIScreen.main.nativeBounds.height // duo-bad
        if UIDevice.current.orientation.isLandscape { layoutSideBySide(width, height) } // duo-bad
        if view.window?.windowScene?.interfaceOrientation.isPortrait == true { layoutStacked() } // duo-bad
        if UIScreen.main.bounds.height > 800 { layoutTall() } // duo-bad
        let card = UIView(frame: CGRect(x: 0, y: 0, width: 393, height: 852)) // duo-bad
        view.addSubview(card)
    }

    func makeLayout(item: NSCollectionLayoutItem, size: NSCollectionLayoutSize) -> NSCollectionLayoutGroup {
        NSCollectionLayoutGroup.horizontal(layoutSize: size, repeatingSubitem: item, count: 3) // duo-bad
    }

    func isOldPhone(_ model: String) -> Bool { model == "iPhone14,2" } // duo-bad

    func layoutSideBySide(_ w: CGFloat, _ h: CGFloat) {}
    func layoutStacked() {}
    func layoutTall() {}
}
