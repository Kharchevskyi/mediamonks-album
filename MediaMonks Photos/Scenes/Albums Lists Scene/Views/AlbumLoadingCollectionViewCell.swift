//
//  AlbumLoadingCollectionViewCell.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class AlbumLoadingCollectionViewCell: RetryCollectionViewCell {
    override func startAnimation() {
        UIView.animate(
            withDuration: 1.5,
            animations: {
                self.retryImageView.transform = CGAffineTransform(translationX: -50, y: 0)
            }, completion: { _ in
                UIView.animate(
                    withDuration: 1.5,
                    animations: {
                        self.retryImageView.transform = CGAffineTransform(translationX: 50, y: 0)
                }, completion: { [weak self] _ in
                    self?.startAnimation()
                })
            })
    }
}
