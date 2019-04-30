//
//  PhotosRouter.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

// MARK: - Protocol

protocol PhotosRouting {
    
}

// MARK: - Implementation

final class PhotosRouter {
    private weak var viewController: PhotosViewController?

    init(viewController: PhotosViewController) {
        self.viewController = viewController
    }
}

extension PhotosRouter: PhotosRouting {
    
}
