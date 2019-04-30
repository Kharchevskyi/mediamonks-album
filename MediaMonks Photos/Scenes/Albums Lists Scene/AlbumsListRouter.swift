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
    func show(scene: AlbumsListRouter.Scene)
}

// MARK: - Implementation

final class AlbumsListRouter {
    enum Scene {
        case photos(Int)
    }

    private weak var viewController: AlbumsListViewController?

    init(viewController: AlbumsListViewController) {
        self.viewController = viewController
    }
}

extension AlbumsListRouter: AlbumsListRouting {
    func show(scene: AlbumsListRouter.Scene) {
        switch scene {
        case .photos(let id):
            DispatchQueue.main.async {
                let scene = PhotosConfigurator.scene(with: id)
                self.viewController?.navigationController?.pushViewController(scene, animated: true)
            }
        }
    }
}
