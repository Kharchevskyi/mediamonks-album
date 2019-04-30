//
//  MediaMonksAlbumViewModel.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

struct MediaMonksAlbumViewModel: Equatable {
    let title: NSAttributedString
    let id: Int
}

extension MediaMonksAlbumViewModel {
    init(_ album: MediaMonksAlbum) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.paragraphStyle: paragraph
        ]

        self.title = NSAttributedString(
            string: album.title.firstUppercased(),
            attributes: attributes
        )
        self.id = album.id
    }
}

