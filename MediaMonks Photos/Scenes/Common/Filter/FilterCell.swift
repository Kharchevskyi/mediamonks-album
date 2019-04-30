//
//  FilterCell.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/30/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

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
        imageView.contentMode = .scaleAspectFill
        return self
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
