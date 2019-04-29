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
    private let bar = UIView()

    var image: UIImage?
    var viewModel: MediaMonksPhotoViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        output?.setup()
    }

    private func setupUI() {
        self.imageScrollView = ImageScrollView(frame: self.view.bounds)
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(self.imageScrollView)

        guard let image = image else { return }
        imageScrollView.display(image)


        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)
        bar.backgroundColor = .white
        bar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        let guide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            imageScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            imageScrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            imageScrollView.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 0),
            imageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
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
    func tranisitionSetup() {
        imageScrollView.isHidden = true
        title = viewModel?.title.string
    }

    func tranisitionCleanup() {
        imageScrollView.isHidden = false
    }

    func imageFrame() -> CGRect {
        return imageScrollView.convert(
            imageScrollView.zoomView.frame,
            to: view
        )
    }
}
