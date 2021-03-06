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
        ViewState(state).map { output?.handle(state: $0) }
    }
}

fileprivate extension ViewState where T == MediaMonksPhotoViewModel {
    init?(_ state: State<MediaMonksPhoto>) {
        switch state {
        case .idle:
            self = .idle
        case .failed(let error):
            switch error {
            case .dataMapping:      self = .failed(.message(error.userDescription))
            case .malformedBaseURL: self = .failed(.message(error.userDescription))
            case .request:          self = .failed(.retryable(error.userDescription))
            }
        case .loading(.initial):
            self = .loading(.initial)
        case .loading(.new):
            self = .loading(.new)
        case .loaded(let model):
            let viewModels = model.items.map(MediaMonksPhotoViewModel.init)
            self = .loaded(viewModels)
        }
    }
}
