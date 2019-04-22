//
//  MediaMonksAlbumViewModel.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

struct MediaMonksAlbumViewModel: Equatable {
    let title: NSAttributedString
    let id: Int
}

extension MediaMonksAlbumViewModel {
    init(_ album: MediaMonksAlbum) {
        self.title = NSAttributedString(string: album.title)
        self.id = album.id
    }
}
