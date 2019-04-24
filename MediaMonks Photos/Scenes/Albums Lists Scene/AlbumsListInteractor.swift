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
    func update(with state: State<MediaMonksAlbum>)
}

// MARK: - Implementation

final class AlbumsListInteractor {
    enum Action {
        case setup
        case dispose
        case loadNew
        case retry
    }

    private let output: AlbumsListInteractorOutput
    private let scheduler = QueueScheduler(qos: .background, name: "com.MediaMonks.AlbumsListInteractor.queue")
    private let mediaMonksApi: MediaMonksAPIType
    private var albumsDisposable: Disposable?
    private var state: State<MediaMonksAlbum> = .idle {
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
        scheduler.schedule { [weak self] in
            guard let self = self else { return }
            switch action {
            case .setup:   self.setup()
            case .dispose: self.dispose()
            case .loadNew: self.getAlbums(isInitial: false)
            case .retry:   self.getAlbums(isInitial: false)
            }
        }
    }

    private func setup() {
        getAlbums(isInitial: true)
    }

    private func dispose() {
        albumsDisposable?.dispose()
    }
}

extension AlbumsListInteractor {
    private func getAlbums(isInitial: Bool) {
        if case .loading(.new) = state {
            return
        }
        albumsDisposable = mediaMonksApi.albums(request: AlbumsRequest())
            .producer
            .take(duringLifetimeOf: self).on(
                started: { [weak self] in
                    let loadinState: .State<MediaMonksAlbum>.Loading = isInitial
                        ? .initial
                        : .new
                    self?.state = .loading(loadinState)
                },
                failed: { [weak self] error in
                    self?.state = .failed(error)
                },
                value: { [weak self] albums in
                    self?.state = .loaded(State.Model(items: albums))
                })
                .start()
    }
}
