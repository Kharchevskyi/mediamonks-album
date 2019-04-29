//
//  PhotosViewController.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol PhotosViewControllerInput {
    func handle(state: ViewState<MediaMonksPhotoViewModel>)
}

protocol PhotosViewControllerOutput {
    func handle(action: PhotosInteractor.Action)
}

// MARK: - Implementation

class PhotosViewController: UIViewController {
    enum LocalConstants {
        static let minimalBlocksInRowCount: Int = 6
    }

    let animator = AnimationController()
    private var hideSelectedCell = false
    private var selectedIndex = IndexPath(row: 0, section: 0)

    var output: PhotosViewControllerOutput? 
    private var state: ViewState<MediaMonksPhotoViewModel> = .idle
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private lazy var collectionViewLayout = MosaicCollectionViewLayout(delegate: self)
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )
    private lazy var activityView = CustomRefreshControl(
        text: "Photos",
        refreshControl: refreshControl
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.handle(action: .setup)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        output?.handle(action: .dispose)
    }

    private func setupUI() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.8)

        view.backgroundColor = .black
        view.addSubview(collectionView)
        view.constrainToEdges(collectionView)
        collectionView.backgroundColor = .black
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: AlbumLoadingCollectionViewCell.self)
        collectionView.register(cellType: RetryCollectionViewCell.self)
        collectionView.register(cellType: PhotoCell.self)

        collectionView.addSubview(refreshControl)
        activityView.textColor = .white
        activityView.font = UIFont.boldSystemFont(ofSize: 16)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension PhotosViewController: PhotosViewControllerInput {
    func handle(state newState: ViewState<MediaMonksPhotoViewModel>) {
        self.state = newState
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return state.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch state {
        case .loading(.initial):
            return collectionView.dequeueReusableCell(ofType: AlbumLoadingCollectionViewCell.self, at: indexPath)
                .setup(with: "We are almost here", subtitle: "😻😻😻😻😻", onTap: nil)
        case .loaded(let photos):
            guard let viewModel = photos[safe: indexPath.row] else {
                fatalError("no cell provided")
            }
            let cell = collectionView.dequeueReusableCell(ofType: PhotoCell.self, at: indexPath)
                .setup(with: viewModel)

            if selectedIndex == indexPath, hideSelectedCell {
                cell.alpha = 0
            }
            return cell
        case .failed(.retryable(let message)):
            return collectionView.dequeueReusableCell(ofType: RetryCollectionViewCell.self, at: indexPath)
                .setup(with: message, onTap: { [output] in
                    output?.handle(action: .retry)
                })
        default:
            fatalError("no cell provided for this state")
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case let .loaded(photos) = state else { return }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell,
            let viewModel = photos[safe: indexPath.row]
        else { return }

        let destinationVC = PhotoDetailConfigurator.scene(with: viewModel, image: cell.imageView.image)
        
        selectedIndex = indexPath
        animator.setupImageTransition(
            cell.imageView.image,
            fromDelegate: self,
            toDelegate: destinationVC
        )
        destinationVC.image = cell.imageView.image
        destinationVC.transitioningDelegate = self
        present(destinationVC, animated: true, completion: nil)
    }
}

extension PhotosViewController: MosaicCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, mosaicSizeForItemAt indexPath: IndexPath) -> MosaicLayoutSize {
        if indexPath.item % 12 == 3 {
            return MosaicLayoutSize(numberOfColumns: 4, numberOfRows: 4)
        }
        if indexPath.item % 12 == 8 {
            return MosaicLayoutSize(numberOfColumns: 1, numberOfRows: 1)
        } else if indexPath.item % 12 == 9 {
            return MosaicLayoutSize(numberOfColumns: 1, numberOfRows: 1)
        } else if indexPath.item % 12 == 10 {
            return MosaicLayoutSize(numberOfColumns: 1, numberOfRows: 1)
        } else if indexPath.item % 12 == 11 {
            return MosaicLayoutSize(numberOfColumns: 1, numberOfRows: 1)
        } else {
            return MosaicLayoutSize(numberOfColumns: 2, numberOfRows: 2)
        }
    }

    func collectonView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, geometryInfoFor section: MosaicLayoutSection) -> MosaicLayoutSectionGeometryInfo {
        let rowHeight: CGFloat = (collectionView.bounds.size.width - CGFloat(LocalConstants.minimalBlocksInRowCount - 1))/CGFloat(LocalConstants.minimalBlocksInRowCount)
        let columns =  [
            MosaicLayoutColumn(width: rowHeight),
            MosaicLayoutColumn(width: rowHeight),
            MosaicLayoutColumn(width: rowHeight),
            MosaicLayoutColumn(width: rowHeight),
            MosaicLayoutColumn(width: rowHeight),
            MosaicLayoutColumn(width: rowHeight)
        ]
        let geometryInfo = MosaicLayoutSectionGeometryInfo(
            rowHeight: rowHeight,
            columns: columns,
            minimumInteritemSpacing: 2,
            minimumLineSpacing: 2,
            sectionInset: .zero,
            headerHeight: 0
        )
        return geometryInfo
    }
}

extension PhotosViewController: ImageTransitionProtocol {

    func tranisitionSetup() {
        hideSelectedCell = true
        collectionView.reloadData()
    }

    func tranisitionCleanup() {
        hideSelectedCell = false
        collectionView.reloadData()
    }

    func imageFrame() -> CGRect {
        let attributes = collectionView.layoutAttributesForItem(at: selectedIndex)
        let cellRect = attributes!.frame
        let rect = collectionView.convert(cellRect, to: view)
        return rect
    }
}

extension PhotosViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if let presented = presentedViewController as? PhotoDetailViewController  {
            animator.setupImageTransition(
                presented.image,
                fromDelegate: presented,
                toDelegate: self
            )
        }

        return animator
    }
}



