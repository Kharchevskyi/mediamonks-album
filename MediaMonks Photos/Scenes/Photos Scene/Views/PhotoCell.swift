//
//  PhotoCell.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/25/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let imageView = UIImageView(frame: .zero)

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

        titleLabel.numberOfLines = 0
        imageView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        constrainToEdges(imageView)
        titleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.rightAnchor.constraint(equalTo: imageView.rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
            ])
    }

    @discardableResult
    func setup(with viewModel: MediaMonksPhotoViewModel) -> PhotoCell {
        titleLabel.attributedText = viewModel.title
        imageView.loadImageAsync(with: viewModel.thumbnailUrl)
        return self
    }
}
