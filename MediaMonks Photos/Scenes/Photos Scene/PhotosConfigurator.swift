//
//  PhotosConfigurator.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

extension PhotosViewController: PhotosPresenterOutput { }
extension PhotosInteractor: PhotosViewControllerOutput { }
extension PhotosPresenter: PhotosInteractorOutput { }

struct PhotosConfigurator {
    static func scene(with albumId: Int) -> PhotosViewController {
        let viewController = PhotosViewController()
        let router = PhotosRouter(viewController: viewController)
        let presenter = PhotosPresenter(output: viewController, router: router)
        let interactor = PhotosInteractor(
            output: presenter,
            albumId: albumId,
            mediaMonksApi: MediaMonksAPI.default,
            imageCache: ImageCacheImpl.shared
        )
        viewController.output = interactor
        return viewController
    }
}
