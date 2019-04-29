//
//  CustomNavigationControllerDelegate.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/25/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class CustomNavigationControllerDelegate: NSObject {
    private var interactionController: UIPercentDrivenInteractiveTransition?
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    }()
    private weak var navigationController: UINavigationController?
    private let a = FadeTransition()
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController?.delegate = self
        self.navigationController?.view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let view = self.navigationController?.view else { return }

        switch sender.state {
        case .began:
            let location = sender.location(in: view)
            // check if navigationstack contains more than 1 controller to perform pop animation and > half of a screen
            let isAvailable = navigationController?.viewControllers.count ?? 0 > 1
            if location.x < view.bounds.midX, isAvailable {
                self.interactionController = UIPercentDrivenInteractiveTransition()
                self.navigationController?.popViewController(animated: true)
            }
        case .changed:
            let translation = sender.translation(in: view)
            let percentComplete = abs(translation.x/view.bounds.width)
            interactionController?.update(percentComplete)
        case .ended:
            if sender.velocity(in: view).x > 0 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
        default:
            break
        }
    }
}

extension CustomNavigationControllerDelegate: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {

        return a
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
        ) -> UIViewControllerInteractiveTransitioning? {

        return interactionController
    }
}
 
