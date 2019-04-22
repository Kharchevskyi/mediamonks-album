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
    func update(with state: AlbumsListInteractor.State)
}

protocol AlbumsListPresenterOutput: class {
    func handle(state: AlbumsListViewController.State)
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
    func update(with state: AlbumsListInteractor.State) {
        AlbumsListViewController.State(state).map { output?.handle(state: $0) }
    }
}


// MARK: - Mapping

extension AlbumsListViewController.State {
    init?(_ state: AlbumsListInteractor.State) {
        switch state {
        case .idle:
            self = .idle
        case .failed(let error):
            if let message = error.userDescription() {
                self = .failed(message)
            } else {
                return nil
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
