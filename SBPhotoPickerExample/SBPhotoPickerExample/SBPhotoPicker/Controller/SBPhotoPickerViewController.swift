//
//  SBPhotoPickerViewController.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/10/31.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit
import Photos

open class SBPhotoPickerViewController: UINavigationController {

    /// 完成按钮
    open var doneButton: UIBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: nil, action: nil)
    
    /// 取消按钮
    open var cancelButton: UIBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: nil, action: nil)
    
    open var albumButton: UIButton {
        get {
            return albumTitleView.albumButton
        }
        set {
            albumTitleView.albumButton = newValue
        }
    }
    
    open var settings: SBPhotoPickerSettings = SBSettings()
    
    open var photoCollection: SBPhotoCollection?
    
    open lazy var photoCollections: [SBPhotoCollection] = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        var subtype = PHAssetCollectionSubtype.init(rawValue: PHAssetCollectionSubtype.smartAlbumUserLibrary.rawValue | PHAssetCollectionSubtype.smartAlbumRecentlyAdded.rawValue)!
        
        if #available(iOS 9.0, *) {
            subtype = PHAssetCollectionSubtype.init(rawValue: PHAssetCollectionSubtype.smartAlbumUserLibrary.rawValue | PHAssetCollectionSubtype.smartAlbumRecentlyAdded.rawValue | PHAssetCollectionSubtype.smartAlbumScreenshots.rawValue | PHAssetCollectionSubtype.smartAlbumSelfPortraits.rawValue)!
        }
        
        var tempPhotoCollections = [SBPhotoCollection]()
        let cameraRollResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: nil)
        cameraRollResult.enumerateObjects({ (colletion, idx, stop) in
            let fetchResult = PHAsset.fetchAssets(in: colletion, options: fetchOptions)
            if fetchResult.count > 0 && !(colletion.localizedTitle!.contains("Deleted") || colletion.localizedTitle! == "最近删除") {
                if colletion.localizedTitle! == "Camera Roll" || colletion.localizedTitle! == "相机胶卷" {
                    self.photoCollection = SBPhotoCollection(fetchResult: fetchResult, localizedTitle: colletion.localizedTitle!)
                    tempPhotoCollections.insert(SBPhotoCollection(fetchResult: fetchResult, localizedTitle: colletion.localizedTitle!), at: 0)
                }else {
                    tempPhotoCollections.append(SBPhotoCollection(fetchResult: fetchResult, localizedTitle: colletion.localizedTitle!))
                }
            }
        })
        
        subtype = PHAssetCollectionSubtype.init(rawValue: PHAssetCollectionSubtype.albumRegular.rawValue | PHAssetCollectionSubtype.albumSyncedAlbum.rawValue)!
        let albumResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        albumResult.enumerateObjects({ (colletion, idx, stop) in
            let fetchResult = PHAsset.fetchAssets(in: colletion, options: fetchOptions)
            if fetchResult.count > 0 {
                if colletion.localizedTitle! == "My Photo Stream" || colletion.localizedTitle! == "我的照片流" {
                    tempPhotoCollections.insert(SBPhotoCollection(fetchResult: fetchResult, localizedTitle: colletion.localizedTitle!), at: 1)
                }else {
                    tempPhotoCollections.append(SBPhotoCollection(fetchResult: fetchResult, localizedTitle: colletion.localizedTitle!))
                }
            }
        })
        
        return tempPhotoCollections
    }()
    
    lazy var photosViewController: SBPhotosViewController = {
        let vc = SBPhotosViewController(photoCollections: self.photoCollections,
                                      defaultSelections: self.photoCollection!,
                                      settings: self.settings)
        vc.doneBarButton = self.doneButton
        vc.cancelBarButton = self.cancelButton
        vc.albumTitleView = self.albumTitleView
        return vc
    }()
    
    open var defaultSelections: PHFetchResult<AnyObject>?
    
    var albumTitleView: SBAlbumTitleView = SBAlbumTitleView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.white
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            setViewControllers([photosViewController], animated: false)
        }
    }
}

extension SBPhotoPickerViewController {
    
    //是否授权
    open class func authorize(_ status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(), fromViewController: UIViewController, completion: @escaping (_ authorized: Bool) -> Void) {
        switch status {
        case .authorized: //已授权
            completion(true)
        case .notDetermined: //不确定
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                dispatch_async_safely_to_main_queue({
                    self.authorize(status, fromViewController: fromViewController, completion: completion)
                })
            })
        default: ()
            dispatch_async_safely_to_main_queue({
                completion(false)
            })
        }
    }
    
    open override var prefersStatusBarHidden : Bool {
        return settings.fullscreen
    }
}

extension SBPhotoPickerViewController: SBPhotoPickerSettings {
    /// 是否显示状态栏
    open var fullscreen: Bool {
        get {
            return settings.fullscreen
        }
        set {
            settings.fullscreen = newValue
        }
    }
    
    /// 最大选择数量
    open var maxNumberOfSelections: Int {
        get {
            return settings.maxNumberOfSelections
        }
        set {
            settings.maxNumberOfSelections = newValue
        }
    }

    /// 选中的圆圈的颜色
    open var selectionFillColor: UIColor {
        get {
            return settings.selectionFillColor
        }
        set {
            settings.selectionFillColor = newValue
        }
    }

    /// 选中的圆圈的外圈颜色
    open var selectionStrokeColor: UIColor {
        get {
            return settings.selectionStrokeColor
        }
        set {
            settings.selectionStrokeColor = newValue
        }
    }

    /// 选中的阴影颜色
    open var selectionShadowColor: UIColor {
        get {
            return settings.selectionShadowColor
        }
        set {
            settings.selectionShadowColor = newValue
        }
    }

    /// 选中数量数字的属性
    open var selectionTextAttributes: [String: AnyObject] {
        get {
            return settings.selectionTextAttributes
        }
        set {
            settings.selectionTextAttributes = newValue
        }
    }
    
    /// item之间的间距
    open var itemSpacing: CGFloat {
        get {
            return settings.itemSpacing
        }
        set {
            settings.itemSpacing = newValue
        }
    }
    
    /// 根据SizeClass确定一行显示几个item
    open var cellsPerRow: (_ verticalSize: UIUserInterfaceSizeClass, _ horizontalSize: UIUserInterfaceSizeClass) -> Int {
        get {
            return settings.cellsPerRow
        }
        set {
            settings.cellsPerRow = newValue
        }
    }

    /// 第一个cell是否显示拍照
    open var takePhotos: Bool {
        get {
            return settings.takePhotos
        }
        set {
            settings.takePhotos = newValue
        }
    }
    
    /// 第一个cell是否显示实时画面
    open var takeCaremra: Bool {
        get {
            return settings.takeCaremra
        }
        set {
            settings.takeCaremra = newValue
        }
    }
    
    /// 第一个cell是拍照的图片icon
    open var takePhotoIcon: UIImage? {
        get {
            return settings.takePhotoIcon
        }
        set {
            settings.takePhotoIcon = newValue
        }
    }
}
