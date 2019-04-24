//
//  PhotosViewController.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol PhotosViewControllerInput {

}

protocol PhotosViewControllerOutput {
    func setup()
}

// MARK: - Implementation

class PhotosViewController: UIViewController {
    var output: PhotosViewControllerOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        output?.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
}

extension PhotosViewController: PhotosViewControllerInput {

}
