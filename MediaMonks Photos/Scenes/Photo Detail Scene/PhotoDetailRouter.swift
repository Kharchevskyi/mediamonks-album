//
//  PhotoDetailRouter.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

// MARK: - Protocol

protocol PhotoDetailRouting {
    
}

// MARK: - Implementation

final class PhotoDetailRouter {
    private weak var viewController: PhotoDetailViewController?

    init(viewController: PhotoDetailViewController) {
        self.viewController = viewController
    }
}

extension PhotoDetailRouter: PhotoDetailRouting {
    
}
