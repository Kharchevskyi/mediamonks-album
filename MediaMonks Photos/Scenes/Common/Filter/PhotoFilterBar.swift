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

        collectionView.reloadData()
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
            width: collectionView.frame.size.height,
            height: collectionView.frame.size.height
        )
    }
}


final class FilterCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private(set) var imageView = UIImageView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.numberOfLines = 1
        imageView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .monkYellow

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    @discardableResult
    func setup(with filter: PhotoFilterBarViewModel) -> FilterCell {
        titleLabel.text = filter.title
        imageView.image = filter.image
        backgroundColor = .monkYellow
        return self
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
