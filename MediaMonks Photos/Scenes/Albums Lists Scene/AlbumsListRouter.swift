//
//  AlbumsListRouter.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

// MARK: - Protocol

protocol AlbumsListRouting {
    
}

// MARK: - Implementation

final class AlbumsListRouter {
    private weak var viewController: AlbumsListViewController?

    init(viewController: AlbumsListViewController) {
        self.viewController = viewController
    }
}

extension AlbumsListRouter: AlbumsListRouting {
    
}
