import UIKit

final class GalleryViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var bottomToolbarView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Anti-pattern: Hardcoded device size
        view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        view.backgroundColor = .systemBackground
        
        setupCollectionView()
        setupCustomBottomToolbar()
    }
    
    private func setupCollectionView() {
        // Anti-pattern: Device idiom checks picking columns instead of adaptive size
        let columns: CGFloat = (UIDevice.current.userInterfaceIdiom == .phone) ? 3 : 5
        let spacing: CGFloat = 8
        let totalSpacing = spacing * (columns + 1)
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / columns
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70)
        ])
    }
    
    private func setupCustomBottomToolbar() {
        // Anti-pattern: Custom bottom UIView toolbar pinned instead of UIToolbar/system toolbar
        bottomToolbarView = UIView()
        bottomToolbarView.backgroundColor = .secondarySystemBackground
        bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomToolbarView)
        
        NSLayoutConstraint.activate([
            bottomToolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomToolbarView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Anti-pattern: Manual fixed space and symbol-only buttons without titles
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareTapped))
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 30
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteTapped))
        
        // Anti-pattern: Custom ellipsis button for overflow
        let overflowButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(overflowTapped))
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.items = [shareButton, fixedSpace, deleteButton, fixedSpace, overflowButton]
        bottomToolbarView.addSubview(toolbar)
    }
    
    @objc private func shareTapped() {}
    @objc private func deleteTapped() {}
    @objc private func overflowTapped() {}
}
