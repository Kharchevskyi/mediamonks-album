//
//  AlbumsListConfigurator.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

extension AlbumsListViewController: AlbumsListPresenterOutput { }
extension AlbumsListInteractor: AlbumsListViewControllerOutput { }
extension AlbumsListPresenter: AlbumsListInteractorOutput { }

struct AlbumsListConfigurator {
    static func scene() -> AlbumsListViewController {
        let viewController = AlbumsListViewController() 
        let router = AlbumsListRouter(viewController: viewController)
        let presenter = AlbumsListPresenter(output: viewController, router: router)
        let interactor = AlbumsListInteractor(output: presenter, mediaMonksApi: MediaMonksAPI.default)
        viewController.output = interactor
        return viewController
    }
}
