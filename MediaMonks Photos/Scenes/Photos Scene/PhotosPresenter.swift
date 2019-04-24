//
//  PhotosPresenter.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol PhotosPresenterInput: class {
    func update(with state: State<MediaMonksPhoto>)
}

protocol PhotosPresenterOutput: class {
    func handle(state: ViewState<MediaMonksPhotoViewModel>)
}

// MARK: - Implementation

final class PhotosPresenter {
    private weak var output: PhotosPresenterOutput?
    private let router: PhotosRouting

    init(output: PhotosPresenterOutput, router: PhotosRouting) {
        self.output = output
        self.router = router
    }
}

extension PhotosPresenter: PhotosPresenterInput {
    func update(with state: State<MediaMonksPhoto>) {
        
    }
}
