//
//  MediaMonksApiRequest.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

protocol MediaMonksApiRequest {
    var path: String { get }
}

struct AlbumsRequest: MediaMonksApiRequest {
    static var `default`: AlbumsRequest = AlbumsRequest(path: "albums")

    let path: String

    init(path: String) {
        self.path = path
    }
}

struct PhotoRequest: MediaMonksApiRequest {
    let path: String

    init(path: String) {
        self.path = path
    }

    init(albumId: Int) {
        self.init(path: "albums/\(albumId)/photos")
    }
}
