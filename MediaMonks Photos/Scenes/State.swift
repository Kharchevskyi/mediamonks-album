//
//  State.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

enum State<T> {
    case idle
    case loading(Loading)
    case failed(APIError)
    case loaded(Model)

    enum Loading {
        case initial
        case new
    }

    struct Model {
        let items: [T]
    }
}
