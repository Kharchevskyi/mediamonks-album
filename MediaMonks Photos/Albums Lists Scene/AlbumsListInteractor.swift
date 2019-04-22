//
//  AlbumsListInteractor.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa

// MARK: - Protocols

protocol AlbumsListInteractorInput {
    func handle(action: AlbumsListInteractor.Action)
}

protocol AlbumsListInteractorOutput {
    func update(with state: AlbumsListInteractor.State)
}

// MARK: - Implementation

final class AlbumsListInteractor {
    enum State {
        case idle
        case loading(Loading)
        case failed(APIError)
        case loaded(Model)

        enum Loading {
            case initial
            case new
        }

        struct Model {
            let items: [MediaMonksAlbum]
        }
    }

    enum Action {
        case setup
        case dispose
    }

    private let output: AlbumsListInteractorOutput
    private let mediaMonksApi: MediaMonksAPIType
    private var albumsDisposable: Disposable?
    private var state: State = .idle {
        didSet {
            output.update(with: state)
        }
    }

    init(
        output: AlbumsListInteractorOutput,
        mediaMonksApi: MediaMonksAPIType
    ) {
        self.output = output
        self.mediaMonksApi = mediaMonksApi
    }
}

extension AlbumsListInteractor: AlbumsListInteractorInput {
    func handle(action: AlbumsListInteractor.Action) {
        switch action {
        case .setup: setup()
        case .dispose: dispose()
        }
    }

    private func setup() {
        getAlbums()
    }

    private func dispose() {
        albumsDisposable?.dispose()
    }
}

extension AlbumsListInteractor {
    private func getAlbums() {
        albumsDisposable = mediaMonksApi.albums(request: AlbumsRequest())
            .producer
            .take(duringLifetimeOf: self).on(
                started: { [weak self] in
                    self?.state = .loading(.initial)
                },
                failed: { [weak self] error in
                    self?.state = .failed(error)
                },
                value: { [weak self] albums in
                    self?.state = .loaded(AlbumsListInteractor.State.Model(items: albums))
                })
                .start()
    }
}
