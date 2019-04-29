//
//  FadeTransition.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class FadeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var transitionDuration: TimeInterval = 0.5
    var startingAlpha: CGFloat = 0.0

    convenience init(transitionDuration: TimeInterval, startingAlpha: CGFloat) {
        self.init()
        self.transitionDuration = transitionDuration
        self.startingAlpha = startingAlpha
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!

        toView.alpha = startingAlpha
        fromView.alpha = 0.8

        toView.frame = containerView.frame
        containerView.addSubview(toView)

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: { () -> Void in
            toView.alpha   = 1.0
            fromView.alpha = 0.0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
