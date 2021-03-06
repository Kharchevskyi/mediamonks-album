//
//  MediaMonksApiRequest.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

enum ApiEndpoint {
    case albums
    case photos(_ albumId: Int)

    var path: String {
        switch self {
        case .albums: return "/albums"
        case .photos(let albumId): return "/albums/\(albumId)/photos"
        }
    }
}

protocol MediaMonksApiRequest {
    var path: ApiEndpoint { get }
}

struct AlbumsRequest: MediaMonksApiRequest {
    let path: ApiEndpoint = .albums
}

struct PhotoRequest: MediaMonksApiRequest {
    let path: ApiEndpoint

    init(albumId: Int) {
        path = .photos(albumId)
    }
} 
