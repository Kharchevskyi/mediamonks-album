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
    private var initialTouchPoint: CGPoint?
    private var initialCenter: CGPoint?

    var image: UIImage?
    var viewModel: MediaMonksPhotoViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        output?.setup()
    }

    private func setupUI() {
        self.imageScrollView = ImageScrollView(frame: view.bounds)
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

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        imageScrollView.zoomView.addGestureRecognizer(panGesture)
    }

    @objc private func handleTap() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func handlePan(gesture: UIPanGestureRecognizer) {

        let touchPoint = gesture.location(in: view)

        switch gesture.state {
        case .began:
            initialCenter = imageScrollView.center
            initialTouchPoint = touchPoint
        case .changed:
            let translation = gesture.translation(in: view)
            imageScrollView.center = CGPoint(
                x: imageScrollView.center.x + translation.x,
                y: imageScrollView.center.y + translation.y
            )
            gesture.setTranslation(.zero, in: view)
        case .ended, .cancelled:
            guard let initialTouchPoint = initialTouchPoint else { return }
            if abs(touchPoint.y - initialTouchPoint.y) > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.imageScrollView.center = self.initialCenter ?? .zero
                })
            }
        default:
            UIView.animate(withDuration: 0.3, animations: {
                self.imageScrollView.center = self.initialCenter ?? .zero
            })
            initialTouchPoint = nil
        }
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

enum PanDirection: Equatable {
    case up, down, left, right
    public var isVertical: Bool { return [.up, .down].contains(self) }
    public var isHorizontal: Bool { return !isVertical }
}

extension UIPanGestureRecognizer {
    var direction: PanDirection? {
        let velocity = self.velocity(in: view)
        let isVertical = abs(velocity.y) > abs(velocity.x)
        switch (isVertical, velocity.x, velocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, let x, _) where x > 0: return .right
        case (false, let x, _) where x < 0: return .left
        default: return nil
        }

    }

}
