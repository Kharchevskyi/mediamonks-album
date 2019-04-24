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

}

// MARK: - Implementation

final class PhotosInteractor {
    enum Action {
        case setup, retry
    }
    
    private let output: PhotosInteractorOutput
    private let albumId: String
    private let scheduler = QueueScheduler(qos: .background, name: "com.MediaMonks.PhotosInteractor.queue")
    private let mediaMonksApi: MediaMonksAPIType

    init(output: PhotosInteractorOutput, albumId: String, mediaMonksApi: MediaMonksAPIType) {
        self.output = output
        self.albumId = albumId
        self.mediaMonksApi = mediaMonksApi
    }
}

extension PhotosInteractor: PhotosInteractorInput {
    func handle(action: PhotosInteractor.Action) {
        switch action {
        case .setup: setup()
        case .retry: retry()
        }
    }

    private func setup() {

    }

    private func retry() {

    }
}
