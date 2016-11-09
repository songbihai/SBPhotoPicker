//
//  SBPhoto.swift
//  SBPhotoPickerDemo
//
//  Created by 宋碧海 on 16/8/31.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit
import Photos

public enum SBPhotoType: Int {
    case urlString
    case imageName
    case imageFile
    case asset
}

open class SBPhoto: NSObject {
    open var selected: Bool = false
    open var placeholderImage: UIImage?
    
    open fileprivate(set) var urlStr: String = ""
    open fileprivate(set) var imageName: String = ""
    open fileprivate(set) var imageFile: String = ""
    open fileprivate(set) var asset: PHAsset?
    open fileprivate(set) var type: SBPhotoType
    
    @available(iOS, unavailable, message: "不能用这个初始化")
    public override init() { type = .imageFile }
    
    public init (urlStr: String) {
        self.urlStr = urlStr
        self.type = .urlString
        super.init()
    }
    
    public init (imageName: String) {
        self.imageName = imageName
        self.type = .imageName
        super.init()
    }
    
    public init (imageFile: String) {
        self.imageFile = imageFile
        self.type = .imageFile
        super.init()
    }
    
    public init (asset: PHAsset) {
        self.asset = asset
        self.type = .asset
        super.init()
    }
    
    open func requestImage(_ targetSize: CGSize = CGSize.zero, contentMode: PHImageContentMode = .aspectFill, resultHandler: @escaping (UIImage?) -> Void) -> PHImageRequestID? {
        switch type {
        case .urlString:
            //待续
            return nil
        case .imageName:
            resultHandler(UIImage(named: imageName))
            return nil
        case .imageFile:
            resultHandler(UIImage(contentsOfFile: imageFile))
            return nil
        case .asset: 
            let options = PHImageRequestOptions()
            return PHCachingImageManager.default().requestImage(for: self.asset!, targetSize: targetSize, contentMode: contentMode, options: options) { (result, _) in
                resultHandler(result)
            }
        }
    }
}
