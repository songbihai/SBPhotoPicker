//
//  UIImageViewModeScaleAspect.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//  https://github.com/VivienCormier/UIImageViewModeScaleAspect

import UIKit

@IBDesignable
open class UIImageViewModeScaleAspect: UIView {
    
    public enum ScaleAspect {
        case fit
        case fill
    }
    
    @IBInspectable open var image: UIImage? {
        didSet {
            transitionImage.image = image
        }
    }
    
    internal var transitionImage: UIImageView
    fileprivate var newTransitionImageFrame: CGRect?
    fileprivate var newSelfFrame: CGRect?
    
    override public init(frame: CGRect) {
        
        transitionImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        transitionImage.contentMode = .scaleAspectFit;
        
        super.init(frame: frame)
        
        addSubview(transitionImage)
        clipsToBounds = true
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        transitionImage = UIImageView()
        transitionImage.contentMode = .center
        
        super.init(coder: aDecoder)
        
        addSubview(transitionImage)
        transitionImage.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        transitionImage.autoresizingMask = [ .flexibleWidth, .flexibleHeight]
        clipsToBounds = true
        
    }
    
    open func animate(_ scaleAspect: ScaleAspect, frame: CGRect? = nil, duration: Double, delay: Double? = nil, completion: ((Bool) -> Void)? = nil) -> Void {
        
        var newFrame = self.frame
        if frame != nil {
            newFrame = frame!
        }
        
        initialeState(scaleAspect, newFrame: newFrame)
        
        var delayAnimation = 0.0
        if delay != nil {
            delayAnimation = delay!
        }
        UIView.animate(withDuration: duration, delay: delayAnimation, options: .allowAnimatedContent, animations: { 
            self.transitionState(scaleAspect)
        }) { (finished) in
            self.endState(scaleAspect)
            completion?(finished)
        }
        
    }
    
    open func initialeState(_ newScaleAspect: ScaleAspect, newFrame: CGRect) -> Void {
        
        precondition(transitionImage.image != nil)
        
        if newScaleAspect == ScaleAspect.fill && contentMode == .scaleAspectFill ||
            newScaleAspect == ScaleAspect.fit && contentMode == .scaleAspectFit {
            print("UIImageViewModeScaleAspect - Warning : You are trying to animate your image to \(contentMode) but it's already set.")
        }
        
        let ratio = transitionImage.image!.size.width / transitionImage.image!.size.height
        
        if newScaleAspect == ScaleAspect.fill {
            newTransitionImageFrame = initialeTransitionImageFrame(newScaleAspect, ratio: ratio, newFrame: newFrame)
        } else {
            transitionImage.frame = initialeTransitionImageFrame(newScaleAspect, ratio: ratio, newFrame: frame)
            transitionImage.contentMode = .scaleAspectFit;
            newTransitionImageFrame = CGRect(x: 0, y: 0, width: newFrame.size.width, height: newFrame.size.height);
        }
        
        newSelfFrame = newFrame
        
    }
    
    open func transitionState(_ scaleAspect: ScaleAspect) -> Void {
        transitionImage.frame = newTransitionImageFrame!
        super.frame = newSelfFrame!
    }
    
    open func endState(_ scaleAspect: ScaleAspect) -> Void {
        if scaleAspect == ScaleAspect.fill {
            transitionImage.contentMode = .scaleAspectFill;
            transitionImage.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height);
        }
    }
        
    override open var frame: CGRect {
        didSet {
            transitionImage.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        }
    }
    
    override open var contentMode: UIViewContentMode {
        get {
            return transitionImage.contentMode
        }
        set(newContentMode) {
            transitionImage.contentMode = newContentMode
        }
    }
    
    fileprivate static func contentMode(_ scaleAspect: ScaleAspect) -> UIViewContentMode {
        switch scaleAspect {
        case .fit:
            return .scaleAspectFit
        case .fill:
            return .scaleAspectFill
        }
    }
    
    fileprivate func initialeTransitionImageFrame(_ scaleAspect: ScaleAspect, ratio: CGFloat, newFrame: CGRect) -> CGRect {
        
        var selectFrameFormula = false
        
        let ratioSelf = newFrame.size.width / newFrame.size.height
        
        if (ratio > ratioSelf ) {
            selectFrameFormula = true
        }
        
        if scaleAspect == ScaleAspect.fill {
            
            if (selectFrameFormula) {
                return CGRect( x: -(newFrame.size.height * ratio - newFrame.size.width) / 2.0, y: 0, width: newFrame.size.height * ratio, height: newFrame.size.height)
            }else{
                return CGRect(x: 0, y: -(newFrame.size.width / ratio - newFrame.size.height) / 2.0, width: newFrame.size.width, height: newFrame.size.width / ratio)
            }
            
        } else {
            
            if (selectFrameFormula) {
                return CGRect( x: -(frame.size.height * ratio - frame.size.width) / 2.0, y: 0, width: frame.size.height * ratio, height: frame.size.height)
            }else{
                return CGRect(x: 0, y: -(frame.size.width / ratio - frame.size.height) / 2.0, width: frame.size.width, height: frame.size.width / ratio)
            }
            
        }
        
    }
    
}
