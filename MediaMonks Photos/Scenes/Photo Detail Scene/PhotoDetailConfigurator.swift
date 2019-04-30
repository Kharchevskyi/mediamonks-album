//
//  PhotoDetailConfigurator.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

extension PhotoDetailViewController: PhotoDetailPresenterOutput { }
extension PhotoDetailInteractor: PhotoDetailViewControllerOutput { }
extension PhotoDetailPresenter: PhotoDetailInteractorOutput { }

struct PhotoDetailConfigurator {
    static func scene(with viewModel: MediaMonksPhotoViewModel, image: UIImage?) -> PhotoDetailViewController {
        let viewController = PhotoDetailViewController()
        viewController.viewModel = viewModel
        viewController.image = image
        
        let router = PhotoDetailRouter(viewController: viewController)
        let presenter = PhotoDetailPresenter(output: viewController, router: router)
        let interactor = PhotoDetailInteractor(output: presenter)
        viewController.output = interactor
        return viewController
    }
}
