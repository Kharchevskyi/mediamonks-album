//
//  PhotoFilterBar.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/30/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa


struct PhotoFilterBarViewModel {
    let image: UIImage?
    let title: String
}

final class PhotoFilterBar: UIView {
    typealias FilterCompletion = (Int) -> Void

    private var onTap: FilterCompletion?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    private var filters: [PhotoFilterBarViewModel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    func setup(with filters: [PhotoFilterBarViewModel], onTap block: FilterCompletion?) {
        self.filters = filters
        self.onTap = block
        collectionView.reloadData()
    }

    private func setupUI() {
        addSubview(collectionView)
        constrainToEdges(collectionView)
        collectionView.register(cellType: FilterCell.self)
    }
}

extension PhotoFilterBar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let filter = filters[safe: indexPath.row] else { return UICollectionViewCell() }
        return collectionView.dequeueReusableCell(ofType: FilterCell.self, at: indexPath)
            .setup(with: filter)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTap?(indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(
            width: 80,
            height: 80
        )
    }
}
