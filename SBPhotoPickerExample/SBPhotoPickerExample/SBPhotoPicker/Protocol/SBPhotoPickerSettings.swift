//
//  SBPhotoPickerSettings.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

public protocol SBPhotoPickerSettings {
    var fullscreen: Bool { get set }
    
    var maxNumberOfSelections: Int { get set }

    var selectionFillColor: UIColor { get set }

    var selectionStrokeColor: UIColor { get set }

    var selectionShadowColor: UIColor { get set }

    var selectionTextAttributes: [String: AnyObject] { get set }

    var takePhotos: Bool { get set }
    
    var takeCaremra: Bool { get set }

    var takePhotoIcon: UIImage? { get set }
    
    var itemSpacing: CGFloat { get set}
    
    var cellsPerRow: (_ verticalSize: UIUserInterfaceSizeClass, _ horizontalSize: UIUserInterfaceSizeClass) -> Int { get set }
}
