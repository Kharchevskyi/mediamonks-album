//
//  PhotoDetailBar.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class PhotoDetailBar: UIView {
    private(set) var titleLabel = UILabel()
    private let dismisButton = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(dismisButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dismisButton.translatesAutoresizingMaskIntoConstraints = false

        let buttonWidth: CGFloat = 44
        let statusBarHeight = UIApplication.shared.statusBarFrame.height

        NSLayoutConstraint.activate([
            dismisButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            dismisButton.topAnchor.constraint(equalTo: topAnchor, constant: statusBarHeight+8),
            dismisButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            dismisButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            titleLabel.leftAnchor.constraint(equalTo: dismisButton.rightAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: statusBarHeight+8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -buttonWidth-8-8)
        ])

        titleLabel.textColor = UIColor.monkYellow
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center

        dismisButton.image = UIImage(named: "cross")?
            .tinted(with: .monkYellow)
        dismisButton.contentMode = .scaleAspectFit
    }
}
