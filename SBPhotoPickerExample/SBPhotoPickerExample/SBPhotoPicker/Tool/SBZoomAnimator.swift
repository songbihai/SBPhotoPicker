//
//  SBZoomAnimator.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//  

import UIKit

final class SBZoomAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    var transitionDuration: TimeInterval = 0.3
    
    var sourceImageView: UIImageView?
    var destinationImageView: UIImageView?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to), let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from), let sourceImageView = sourceImageView, let destinationImageView = destinationImageView {
            fromViewController.view?.isUserInteractionEnabled = false
            
            sourceImageView.isHidden = true
            destinationImageView.isHidden = true
            toViewController.view.alpha = 0.0
            fromViewController.view.alpha = 1.0
            containerView.backgroundColor = toViewController.view.backgroundColor
            
            let scalingFrame = containerView.convert(sourceImageView.frame, from: sourceImageView.superview)
            let scalingImage = UIImageViewModeScaleAspect(frame: scalingFrame)
            scalingImage.contentMode = sourceImageView.contentMode
            scalingImage.image = sourceImageView.image
            
            let destinationFrame = toViewController.view.convert(destinationImageView.bounds, from: destinationImageView.superview)
            if destinationImageView.contentMode == .scaleAspectFit {
                scalingImage.initialeState(.fit, newFrame: destinationFrame)
            } else {
                scalingImage.initialeState(.fill, newFrame: destinationFrame)
            }
            
            containerView.addSubview(toViewController.view)
            containerView.addSubview(scalingImage)
            
            UIView.animate(withDuration: transitionDuration,
                delay: 0.0,
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    fromViewController.view.alpha = 0.0
                    toViewController.view.alpha = 1.0
                    
                    if destinationImageView.contentMode == .scaleAspectFit {
                        scalingImage.transitionState(.fit)
                    } else {
                        scalingImage.transitionState(.fill)
                    }
                }, completion: { (finished) -> Void in
                    
                    if destinationImageView.contentMode == .scaleAspectFit {
                        scalingImage.endState(.fit)
                    } else {
                        scalingImage.endState(.fill)
                    }
                    scalingImage.removeFromSuperview()
                    
                    destinationImageView.isHidden = false
                    sourceImageView.isHidden = false
                    fromViewController.view.alpha = 1.0
                    
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    
                    fromViewController.view?.isUserInteractionEnabled = true
            })
        }
    }
}
