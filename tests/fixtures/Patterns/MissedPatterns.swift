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

struct ToolbarPatternsView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            Text("Body")
                .ignoresSafeArea(.container, edges: .all) // duo-bad
                .toolbarVerticalBehavior(.disabled) // duo-bad
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack { // duo-bad
                            Button { } label: { Image(systemName: "star") } // duo-bad
                            Button { } label: { Label("Share", systemImage: "square.and.arrow.up") }
                        }
                    }
                }
            HStack {
                Button(action: { selectedTab = 0 }) { Text("Home") } // duo-bad
            }
        }
    }
}

struct BottomTabBar: View { // duo-bad
    var body: some View { Text("Tabs") }
}

final class LegacyBarsViewController: UIViewController {
    let bar = UIToolbar() // duo-bad
    let tabs = UITabBar(frame: .zero) // duo-bad

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.bounds.width - view.safeAreaInsets.left * 2 // duo-bad
        let scale = UIScreen.main.scale // duo-bad
        let share = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), menu: nil) // duo-bad
        navigationItem.rightBarButtonItem = share
        _ = (width, scale)
    }

    override var preferredVerticalBarBehavior: UIVerticalBarBehavior { .disabled } // duo-bad
}

final class FancyToolbar: UIToolbar {} // duo-bad
