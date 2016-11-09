//
//  UIImage+SBAdd.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/10/31.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

public extension UIImage {
    //修正方向
    public class func fixImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }
        var transform = CGAffineTransform.identity
        switch image.imageOrientation {
        case .down: fallthrough
        case .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case .left: fallthrough
        case .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        case .right: fallthrough
        case .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -CGFloat(M_PI_2))
        default: break
        }
        
        switch image.imageOrientation {
        case .upMirrored: fallthrough
        case .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored: fallthrough
        case .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default: break
        }
        
        let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height),
                                        bitsPerComponent: (image.cgImage?.bitsPerComponent)!, bytesPerRow: 0,
                                        space: (image.cgImage?.colorSpace!)!,
                                        bitmapInfo: (image.cgImage?.bitmapInfo.rawValue)!)
        ctx?.concatenate(transform)
        switch (image.imageOrientation) {
        case .left: fallthrough
        case .leftMirrored: fallthrough
        case .right: fallthrough
        case .rightMirrored:
            ctx?.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: image.size.height,height: image.size.width))
        default:
            ctx?.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: image.size.width,height: image.size.height))
        }
        
        let cgimg = ctx?.makeImage()
        let newImage = UIImage.init(cgImage: cgimg!)
        return newImage
    }
    
    //调整大小
    public class func scaleImage(_ image: UIImage, toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(toSize)
        image.draw(in: CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage!;
    }
}
