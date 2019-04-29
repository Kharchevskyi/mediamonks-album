//
//  PhotoDetailPresenter.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol PhotoDetailPresenterInput: class {

}

protocol PhotoDetailPresenterOutput: class {

}

// MARK: - Implementation

final class PhotoDetailPresenter {
    private weak var output: PhotoDetailPresenterOutput?
    private let router: PhotoDetailRouting

    init(output: PhotoDetailPresenterOutput, router: PhotoDetailRouting) {
        self.output = output
        self.router = router
    }
}

extension PhotoDetailPresenter: PhotoDetailPresenterInput {

}
