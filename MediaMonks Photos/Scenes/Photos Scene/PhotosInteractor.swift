//
//  PhotosInteractor.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa

// MARK: - Protocols

protocol PhotosInteractorInput {
    func handle(action: PhotosInteractor.Action)
}

protocol PhotosInteractorOutput {
    func update(with state: State<MediaMonksPhoto>)
}

// MARK: - Implementation

final class PhotosInteractor {
    enum Action {
        case setup, retry, dispose
    }
    
    private let output: PhotosInteractorOutput
    private let albumId: Int
    private let scheduler = QueueScheduler(qos: .background, name: "com.MediaMonks.PhotosInteractor.queue")
    private let mediaMonksApi: MediaMonksAPIType
    private let imageCache: ImageCache
    private var photosDisposable: Disposable?
    private var state: State<MediaMonksPhoto> = .idle {
        didSet {
            output.update(with: state)
        }
    }

    init(
        output: PhotosInteractorOutput,
        albumId: Int,
        mediaMonksApi: MediaMonksAPIType,
        imageCache: ImageCache
    ) {
        self.output = output
        self.albumId = albumId
        self.mediaMonksApi = mediaMonksApi
        self.imageCache = imageCache
    }
}

extension PhotosInteractor: PhotosInteractorInput {
    func handle(action: PhotosInteractor.Action) {
        scheduler.schedule { [weak self] in
            guard let self = self else { return }
            switch action {
            case .setup:   self.setup()
            case .retry:   self.retry()
            case .dispose: self.dispose()
            }
        }
    }

    private func setup() {
        getAlbums(isInitial: true)
    }

    private func retry() {
        getAlbums(isInitial: false)
    }

    private func getAlbums(isInitial: Bool) {
        if case .loading(.new) = state {
            return
        }
        photosDisposable = mediaMonksApi.photos(request: PhotoRequest(albumId: albumId))
            .producer
            .take(duringLifetimeOf: self).on(
                started: { [weak self] in
                    let loadinState: State<MediaMonksPhoto>.Loading = isInitial
                        ? .initial
                        : .new
                    self?.state = .loading(loadinState)
                },
                failed: { [weak self] error in
                    self?.state = .failed(error)
                },
                value: { [weak self] photos in
                    self?.state = .loaded(State.Model(items: photos))
                })
                .start()
    }

    private func dispose() {
        photosDisposable?.dispose()
        imageCache.clear()
    }
}
