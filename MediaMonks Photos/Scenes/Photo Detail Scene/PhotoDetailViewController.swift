//
//  PhotoDetailViewController.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol PhotoDetailViewControllerInput {

}

protocol PhotoDetailViewControllerOutput {
    func setup()
}

// MARK: - Implementation

class PhotoDetailViewController: UIViewController {
    var output: PhotoDetailViewControllerOutput?
    private lazy var imageScrollView = ImageScrollView(frame: self.view.bounds)
    var image: UIImage?
    var viewModel: MediaMonksPhotoViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        output?.setup()
    }

    private func setupUI() {
        self.imageScrollView = ImageScrollView(frame: self.view.bounds)
        self.view.addSubview(self.imageScrollView)

        guard let image = image else { return }
        imageScrollView.display(image)

        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)
        bar.backgroundColor = .black
        bar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bar.leftAnchor.constraint(equalTo: guide.leftAnchor),
            bar.rightAnchor.constraint(equalTo: guide.rightAnchor),
            bar.topAnchor.constraint(equalTo: guide.topAnchor),
            bar.heightAnchor.constraint(equalToConstant: 40)
            ])
    }

    @objc private func handleTap() {
        dismiss(animated: true, completion: nil)
    }

}

extension PhotoDetailViewController: PhotoDetailViewControllerInput {

}

extension PhotoDetailViewController: ImageTransitionProtocol {
    func tranisitionSetup(){
        imageScrollView.isHidden = true
        title = viewModel?.title.string
    }

    func tranisitionCleanup(){
        imageScrollView.isHidden = false
    }

    func imageFrame() -> CGRect{
        return imageScrollView.zoomView.frame
    }
}
