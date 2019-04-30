//
//  PhotoDetailViewController.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

// MARK: - Protocols

protocol PhotoDetailViewControllerInput {

}

protocol PhotoDetailViewControllerOutput {
    func setup()
}

// MARK: - Implementation

class PhotoDetailViewController: UIViewController, PhotoDetailViewControllerInput {
    private enum LocalConstants {
        static let filterHeight: CGFloat = 100
    }

    var output: PhotoDetailViewControllerOutput?
    private lazy var imageScrollView = ImageScrollView(frame: self.view.bounds)
    private let bar = PhotoDetailBar()
    private var initialTouchPoint: CGPoint?
    private var initialCenter: CGPoint?
    private let descritpionLabel = InsetsTextLabel()
    private let filterBar = PhotoFilterBar()
    private var filterHeightConstraint = NSLayoutConstraint()

    var image: UIImage?
    var viewModel: MediaMonksPhotoViewModel?
    var shouldUploadOriginal = true
    private var filters: [PhotoFilterBarViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        output?.setup()
    }

    private func setupUI() {
        self.imageScrollView = ImageScrollView(frame: view.bounds)
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.mainColor
        imageScrollView.backgroundColor = Constants.Colors.mainColor
        view.addSubview(self.imageScrollView)

        guard let image = image else { return }
        imageScrollView.display(image)

        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)

        bar.backgroundColor = .monkGray
        bar.onTapAction { [weak self] in
            self?.toggleFilters()
        }

        bar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        let guide = view.safeAreaLayoutGuide

        let descriptionView = UIView()
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionView)
        descriptionView.backgroundColor = .monkGray
        descritpionLabel.translatesAutoresizingMaskIntoConstraints = false
        descritpionLabel.font = UIFont.boldSystemFont(ofSize: 14)
        descritpionLabel.textAlignment = .center
        descritpionLabel.numberOfLines = 0
        descritpionLabel.textColor = .monkYellow
        view.addSubview(descritpionLabel)
        descritpionLabel.backgroundColor = .monkGray

        filterBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterBar)
        filterBar.backgroundColor = .monkYellow

        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        filterHeightConstraint = filterBar.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            imageScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            imageScrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            imageScrollView.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 0),
            imageScrollView.bottomAnchor.constraint(equalTo: descritpionLabel.topAnchor, constant: 0),
            bar.leftAnchor.constraint(equalTo: guide.leftAnchor),
            bar.rightAnchor.constraint(equalTo: guide.rightAnchor),
            bar.topAnchor.constraint(equalTo: guide.topAnchor, constant: -statusBarHeight),
            bar.heightAnchor.constraint(equalToConstant: statusBarHeight + 40),
            descritpionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            descritpionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            descritpionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            descritpionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            descriptionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            descriptionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            descriptionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            descriptionView.heightAnchor.constraint(equalToConstant: 40),
            filterHeightConstraint,
            filterBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            filterBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            filterBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        imageScrollView.zoomView.addGestureRecognizer(panGesture)
    }

    @objc private func handleTap() {
        TapTicFeedback.generate(.medium)
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
                TapTicFeedback.generate(.medium)
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

    func imageForTransition() -> UIImage? {
        return imageScrollView.zoomView.image ?? image
    }
}

extension PhotoDetailViewController {
    func simpleBlurFilterExample(inputImage: UIImage) -> UIImage {
        // convert UIImage to CIImage
        let inputCIImage = CIImage(image: inputImage)!

        // Create Blur CIFilter, and set the input image
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
        blurFilter.setValue(8, forKey: kCIInputRadiusKey)

        // Get the filtered output image and return it
        let outputImage = blurFilter.outputImage!
        return UIImage(ciImage: outputImage)
    }

    @objc private func toggleFilters() {
        if filterHeightConstraint.constant == 0 {
            filterHeightConstraint.constant = LocalConstants.filterHeight
            showFilters()
        } else {
            filterHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in

            })
        }
    }

    private func showFilters() {
        guard filters.isEmpty else {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            return
        }

        applyFilters()
    }

    private func applyFilters() {
        guard let image = imageScrollView.zoomView.image else { return }
        PhotoFilter.allFilteredImages(with: image)
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .on { [weak self] filters in
                guard let self = self else { return }

                self.filters = filters.map {
                    PhotoFilterBarViewModel.init(image: $0.0, title: $0.1.title)
                }
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    self.filterBar.setup(with: self.filters) { [weak self] index in
                        guard let image = self?.filters[safe: index]?.image else { return }
                        self?.imageScrollView.display(image)
                    }
                })
            }
            .start()
    }

}

extension PhotoDetailViewController: ImageTransitionProtocol {
    func tranisitionSetup() {
        imageScrollView.isHidden = true
        bar.titleLabel.text = viewModel?.title
            .string
            .components(separatedBy: " ")
            .first
        descritpionLabel.text = viewModel?.title.string

        if shouldUploadOriginal {
            imageScrollView.setImage(with: viewModel?.photoUrl)
        }
        applyFilters()
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

