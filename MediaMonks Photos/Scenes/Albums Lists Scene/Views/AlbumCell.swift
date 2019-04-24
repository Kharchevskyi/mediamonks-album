//
//  AlbumCell.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/23/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class AlbumCell: UICollectionViewCell {
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        constrainToEdges(
            titleLabel,
            insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        )
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        backgroundColor = UIColor.darkGray
    }

    @discardableResult
    func setup(with viewModel: MediaMonksAlbumViewModel) -> AlbumCell {
        titleLabel.attributedText = viewModel.title

        return self
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }
}
