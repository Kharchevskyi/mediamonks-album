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
    func setup()
}

protocol PhotosInteractorOutput {

}

// MARK: - Implementation

final class PhotosInteractor {
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
    func setup() {
        // perform any initial tasks here (i.e. data loading, passing existing data, etc.)
        // and pass results to the output (i.e. `output.refreshUsers(with: users)`)
    }
}
