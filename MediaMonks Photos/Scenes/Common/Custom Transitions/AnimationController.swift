//
//  ZoomAnimator.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

protocol ImageTransitionProtocol {
    func tranisitionSetup()
    func tranisitionCleanup()
    func imageFrame() -> CGRect
}

final class AnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private var image: UIImage?
    private var fromDelegate: ImageTransitionProtocol?
    private var toDelegate: ImageTransitionProtocol?

    func setupImageTransition(_ image: UIImage?, fromDelegate: ImageTransitionProtocol, toDelegate: ImageTransitionProtocol){
        self.image = image
        self.fromDelegate = fromDelegate
        self.toDelegate = toDelegate
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fromDelegate?.tranisitionSetup()
        toDelegate?.tranisitionSetup()

        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: true),
            let toSnapshot = toVC.view.snapshotView(afterScreenUpdates: true)
        else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }

        let containerView = transitionContext.containerView

        toVC.view.frame = transitionContext.finalFrame(for: toVC)

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = fromDelegate?.imageFrame() ?? .zero

        imageView.clipsToBounds = true
        containerView.addSubview(imageView)

        fromSnapshot.frame = fromVC.view.frame
        containerView.addSubview(fromSnapshot)


        toSnapshot.frame = fromVC.view.frame
        containerView.addSubview(toSnapshot)
        toSnapshot.alpha = 0


        containerView.bringSubviewToFront(imageView)
        let toFrame = toDelegate?.imageFrame() ?? .zero

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseOut,
            animations: {
                toSnapshot.alpha = 1
                imageView.frame = toFrame
            }, completion: { _ in
                imageView.removeFromSuperview()
                fromSnapshot.removeFromSuperview()
                toSnapshot.removeFromSuperview()

                self.toDelegate?.tranisitionCleanup()
                self.fromDelegate?.tranisitionCleanup()

                if !transitionContext.transitionWasCancelled {
                    containerView.addSubview(toVC.view)
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
    }

}
