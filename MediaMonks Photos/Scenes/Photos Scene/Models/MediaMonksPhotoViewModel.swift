//
//  MediaMonksPhotoViewModel.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

struct MediaMonksPhotoViewModel: Equatable {
    let photoId: Int
    let title: NSAttributedString
    let photoUrl: String
    let thumbnailUrl: String
}

extension MediaMonksPhotoViewModel {
    init(_ photo: MediaMonksPhoto) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 8),
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.paragraphStyle: paragraph
        ]

        self.title = NSAttributedString(
            string: photo.title.firstUppercased(),
            attributes: attributes
        )
        self.photoId = photo.id
        self.thumbnailUrl = photo.thumbnailUrl
        self.photoUrl = photo.url
    }
}
