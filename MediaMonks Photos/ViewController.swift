//
//  ViewController.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/21/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        MediaMonksAPI.default.albums(request: AlbumsRequest.default).on(
            failed: { _ in },
            value: { _ in })
            .start()


        MediaMonksAPI.default.photos(request: PhotoRequest(albumId: 1)).on(
            failed: { _ in },
            value: { _ in })
            .start()

    }
}



