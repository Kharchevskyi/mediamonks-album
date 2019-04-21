//
//  MediaMonksPhoto.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

struct MediaMonksPhoto: Codable {
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
} 
