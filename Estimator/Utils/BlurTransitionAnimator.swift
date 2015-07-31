//
//  BlurTransitionAnimator.swift
//  Estimator
//
//  Created by 전수열 on 7/31/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import UIKit


public final class BlurTransitionAnimator: NSObject {

    private var screenshotView = UIImageView()
    private var dimView = UIView()

}


// MARK: - UIViewControllerTransitioningDelegate

extension BlurTransitionAnimator: UIViewControllerTransitioningDelegate {

    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }

}


// MARK: - UIViewControllerAnimatedTransitioning

extension BlurTransitionAnimator: UIViewControllerAnimatedTransitioning {

    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!

        let window = UIApplication.sharedApplication().windows.first!
        let duration = self.transitionDuration(transitionContext)

        if toViewController.isBeingPresented() {
            UIGraphicsBeginImageContext(window.bounds.size)
            window.drawViewHierarchyInRect(window.bounds, afterScreenUpdates: false)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            let statusBarHeight = CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
            self.screenshotView.image = screenshot.blurredImageWithRadius(8)
            self.screenshotView.alpha = 0
            self.screenshotView.frame = window.bounds
            self.screenshotView.frame.origin.y = statusBarHeight == 20 ? 0 : -40
            fromViewController.view.addSubview(self.screenshotView)

            self.dimView.backgroundColor = UIColor.blackColor() ~ 50%
            self.dimView.frame = self.screenshotView.bounds
            self.screenshotView.addSubview(self.dimView)

            toViewController.view.frame.origin.y = window.bounds.height
            containerView.addSubview(toViewController.view)
            UIView.animateWithDuration(duration,
                delay: 0,
                usingSpringWithDamping: 500,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self.screenshotView.alpha = 1
                    toViewController.view.frame.origin.y = 0
                },
                completion: { _ in
                    transitionContext.completeTransition(true)
                }
            )
        } else {
            containerView.addSubview(fromViewController.view)
            UIView.animateWithDuration(duration,
                delay: 0,
                usingSpringWithDamping: 500,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self.screenshotView.alpha = 0
                    fromViewController.view.frame.origin.y = window.bounds.height
                },
                completion: { _ in
                    transitionContext.completeTransition(true)
                    self.screenshotView.removeFromSuperview()
                    fromViewController.view.removeFromSuperview()
                }
            )
        }
    }
}
