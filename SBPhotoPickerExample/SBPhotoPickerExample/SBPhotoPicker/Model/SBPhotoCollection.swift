//
//  SBPhotoCollection.swift
//  SBPhotoPickerDemo
//
//  Created by 宋碧海 on 16/8/31.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit
import Photos

open class SBPhotoCollection: NSObject {
    open var title: String? {
        get {
            return self.getNewAlbumTitle(localizedTitle)
        }
        set {
            localizedTitle = newValue
        }
    }
    
    open var selectedCount: Int = 0
    
    fileprivate var localizedTitle: String?
    
    open var count: Int {
        return photos?.count ?? 0
    }
    
    fileprivate var photos: [SBPhoto]?
    
    var fetchResult: PHFetchResult<PHAsset>?
    
    open subscript(index: Int) -> SBPhoto? {
        guard index < count else {
            return nil
        }
        return photos?[index]
    }
    
    public init(fetchResult: PHFetchResult<PHAsset>, localizedTitle: String) {
        super.init()
        self.fetchResult = fetchResult
        var tempPhotos = [SBPhoto]()
        fetchResult.enumerateObjects({ (asset, idx, stop) in
            tempPhotos.append(SBPhoto(asset: asset))
        })
        photos = tempPhotos
        self.localizedTitle = localizedTitle
    }
    
    public init(photos: [SBPhoto]) {
        self.photos = photos
        super.init()
    }
    
    public init(photos: SBPhoto...) {
        self.photos = photos
        super.init()
    }
    
    open func containsObject(_ photo: SBPhoto) -> Bool {
        return photos?.contains(photo) ?? false
    }
    
    open func objectAtIndex(_ index: Int) -> SBPhoto? {
        return self[index]
    }
    
    
    open func indexOfObject(_ photo: SBPhoto) -> Int {
        return photos?.index(of: photo) ?? NSNotFound
    }
    
    open func append(_ photo: SBPhoto) {
        photos?.append(photo)
    }
    
    open func remove(_ photo: SBPhoto) {
        let index = self.indexOfObject(photo)
        guard index == NSNotFound else { return }
        photos?.remove(at: index)
    }
    
    fileprivate func getNewAlbumTitle(_ title: String?) -> String {
        var newAlbumTitle: String = " "
        if let oldTitle = title {
            if !(oldTitle.range(of: "Roll")?.isEmpty ?? true) {
                newAlbumTitle = "相机胶卷"
            }else if !(oldTitle.range(of: "Stream")?.isEmpty ?? true) {
                newAlbumTitle = "我的照片流"
            }else if !(oldTitle.range(of: "Added")?.isEmpty ?? true) {
                newAlbumTitle = "最近添加"
            }else if !(oldTitle.range(of: "Selfies")?.isEmpty ?? true) {
                newAlbumTitle = "自拍"
            }else if !(oldTitle.range(of: "shots")?.isEmpty ?? true) {
                newAlbumTitle = "截屏"
            }else if !(oldTitle.range(of: "Videos")?.isEmpty ?? true) {
                newAlbumTitle = "视频"
            }else {
                newAlbumTitle = oldTitle
            }
        }
        return newAlbumTitle
    }
}
