//
//  MediaPlaylistCollectionViewController.swift
//  StickySplitCollectionViewFlowLayoutIntegration
//
//  Created by Greg Jeckell on 10/2/18.
//

import UIKit
import StickySplitCollectionViewFlowLayout

class MediaPlaylistCollectionViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewLayout: StickySplitCollectionViewFlowLayout!
    @IBOutlet private var blackBackgroundWidthConstraint: NSLayoutConstraint!
    
    // MARK: - UIViewController Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "\(MediaPlayerHeaderCollectionReusableView.self)", bundle: nil),
                                forSupplementaryViewOfKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                withReuseIdentifier: .mainHeaderReuseIdentifier)
        collectionViewLayout.sectionHeadersPinToVisibleBounds = true
        collectionViewLayout.mainHeaderPinsToVisibleBounds = true
        collectionViewLayout.mainHeaderZPosition = .belowAll
        collectionViewLayout.enforcedLayoutMode = .implicit(.right)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustItemSizes()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let animations: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.adjustItemSizes()
        }
        coordinator.animate(alongsideTransition: animations, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func adjustItemSizes() {
        let topInset: CGFloat
        if #available(iOS 11.0, *) {
            topInset = collectionView.adjustedContentInset.top
        } else {
            topInset = collectionView.contentInset.top
        }
        let mainHeaderWidth = min(collectionView.frame.width, collectionView.frame.height - topInset)
        switch collectionViewLayout.layoutMode {
        case .horizontal(_):
            collectionViewLayout.itemSize.width = collectionView.frame.width - mainHeaderWidth
        default:
            collectionViewLayout.itemSize.width = collectionView.frame.width
        }
        let size = CGSize(width: mainHeaderWidth, height: mainHeaderWidth)
        collectionViewLayout.mainHeaderReferenceSize = size
        collectionViewLayout.mainHeaderMinimumReferenceSize = size
        collectionViewLayout.mainHeaderMaximumReferenceSize = size
        blackBackgroundWidthConstraint.constant = collectionViewLayout.layoutMode == .vertical ? 0 : collectionViewLayout.itemSize.width
    }
    
    private func cellIdentifier(for indexPath: IndexPath) -> String {
        switch indexPath.item {
        case 0: return .blankCellReuseIdentifier
        default: return .cellReuseIdentifier
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MediaPlaylistCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = cellIdentifier(for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                      for: indexPath)
        if let standardCell = cell as? StandardCollectionViewCell {
            standardCell.secondaryLabel?.text = "\(indexPath)"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case StickySplitCollectionViewFlowLayout.mainElementKind:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: StickySplitCollectionViewFlowLayout.mainElementKind,
                                                                       withReuseIdentifier: .mainHeaderReuseIdentifier,
                                                                       for: indexPath)
            return cell
        case UICollectionView.elementKindSectionHeader:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                       withReuseIdentifier: .shuffleHeaderReuseIdentifier,
                                                                       for: indexPath)
            return cell
        default:
            assertionFailure("other kinds not implemented")
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MediaPlaylistCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               willDisplaySupplementaryView view: UICollectionReusableView,
                               forElementKind elementKind: String,
                               at indexPath: IndexPath) {
        // iOS 11 specific hack see:
        // https://stackoverflow.com/questions/45215932/uicollectionview-showing-scroll-indicator-for-every-section-header-zindex-broke?noredirect=1&lq=1
        if #available(iOS 11, *) {
            if (elementKind == UICollectionView.elementKindSectionHeader) {
                view.layer.zPosition = 0
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case 0: return CGSize(width: self.collectionViewLayout.itemSize.width, height: 10)
        default: return self.collectionViewLayout.itemSize
        }
    }
}

private extension String {
    static let cellReuseIdentifier = "cell"
    static let blankCellReuseIdentifier = "blankCell"
    static let shuffleHeaderReuseIdentifier = "shuffleHeader"
    static let mainHeaderReuseIdentifier = "mainHeader"
}
