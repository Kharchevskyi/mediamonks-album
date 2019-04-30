//
//  AlbumsListPresenter.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol AlbumsListPresenterInput: class {
    func update(with state: State<MediaMonksAlbum>)
    func proceed(to scene: AlbumsListInteractor.Action.Scene)
}

protocol AlbumsListPresenterOutput: class {
    func handle(state: ViewState<MediaMonksAlbumViewModel>)
}

// MARK: - Implementation

final class AlbumsListPresenter {
    private weak var output: AlbumsListPresenterOutput?
    private let router: AlbumsListRouting

    init(output: AlbumsListPresenterOutput, router: AlbumsListRouting) {
        self.output = output
        self.router = router
    }
}

extension AlbumsListPresenter: AlbumsListPresenterInput {
    func update(with state: State<MediaMonksAlbum>) {
        ViewState(state).map { output?.handle(state: $0) }
    }

    func proceed(to scene: AlbumsListInteractor.Action.Scene)  {
        router.show(scene: AlbumsListRouter.Scene(scene))
    }
}


// MARK: - Mapping

fileprivate extension AlbumsListRouter.Scene {
    init(_ scene: AlbumsListInteractor.Action.Scene) {
        switch scene {
        case .photos(let id):
            self = AlbumsListRouter.Scene.photos(id)
        }
    }
}

fileprivate extension ViewState where T == MediaMonksAlbumViewModel {
    init?(_ state: State<MediaMonksAlbum>) {
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
            let viewModels = model.items.map(MediaMonksAlbumViewModel.init)
            self = .loaded(viewModels)
        }
    }
} 
