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

    var output: PhotosViewControllerOutput? 
    private var state: ViewState<MediaMonksPhotoViewModel> = .idle
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private let collectionViewLayout = UICollectionViewFlowLayout()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
 
    }

    private func setupUI() {
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: AlbumLoadingCollectionViewCell.self)
        collectionView.register(cellType: RetryCollectionViewCell.self)

        let layout = MosaicCollectionViewLayout(delegate: self)

        collectionView.collectionViewLayout = layout
        collectionView.bounces = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension PhotosViewController: PhotosViewControllerInput {
    func handle(state: ViewState<MediaMonksPhotoViewModel>) {

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
//        case .loaded(let items):
//            guard let viewModel = items[safe: indexPath.row] else {
//                fatalError("no cell provided")
//            }
//            return collectionView.dequeueReusableCell(ofType: AlbumCell.self, at: indexPath)
//                .setup(with: viewModel)
        case .failed(.retryable(let message)):
            return collectionView.dequeueReusableCell(ofType: RetryCollectionViewCell.self, at: indexPath)
                .setup(with: message, onTap: { [output] in
                    output?.handle(action: .retry)
                })
        default:
            fatalError("no cell provided for this state")
        }
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
            minimumInteritemSpacing: 1,
            minimumLineSpacing: 1,
            sectionInset: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0),
            headerHeight: 0
        )
        return geometryInfo
    }
}
