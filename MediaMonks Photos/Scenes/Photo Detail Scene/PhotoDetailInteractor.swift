//
//  PhotoDetailInteractor.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

// MARK: - Protocols

protocol PhotoDetailInteractorInput {
    func setup()
}

protocol PhotoDetailInteractorOutput {

}

// MARK: - Implementation

final class PhotoDetailInteractor {
    private let output: PhotoDetailInteractorOutput

    init(output: PhotoDetailInteractorOutput) {
        self.output = output
    }
}

extension PhotoDetailInteractor: PhotoDetailInteractorInput {
    func setup() {
        // perform any initial tasks here (i.e. data loading, passing existing data, etc.)
        // and pass results to the output (i.e. `output.refreshUsers(with: users)`)
    }
}
