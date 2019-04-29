//
//  AlbumCell.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/23/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class AlbumCell: UICollectionViewCell {
    private let gradient = RadialGradientLayer()

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
        layer.addSublayer(gradient)
        gradient.colors = [
            UIColor(red: 87, green: 80, blue: 86).cgColor,
            UIColor(red: 50, green: 55, blue: 70).cgColor
        ]
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        constrainToEdges(
            titleLabel,
            insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        )
        titleLabel.numberOfLines = 0
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.monkYellow.cgColor
    }

    @discardableResult
    func setup(with viewModel: MediaMonksAlbumViewModel) -> AlbumCell {
        titleLabel.attributedText = viewModel.title

        return self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2
        gradient.cornerRadius = bounds.size.width / 2
        gradient.frame = bounds
    }
}

