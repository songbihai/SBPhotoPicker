//
//  SBSettings.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

class SBSettings: SBPhotoPickerSettings {
    
    var fullscreen: Bool = false
    
    var maxNumberOfSelections: Int = 9
    
    var selectionFillColor: UIColor = UIView().tintColor
    
    var selectionStrokeColor: UIColor = UIColor.white
    
    var selectionShadowColor: UIColor = UIColor.black
    
    var selectionTextAttributes: [String: AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        return [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 10.0),
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: UIColor.white
        ]
    }()
    
    var itemSpacing: CGFloat = 2.0
    
    var cellsPerRow: (_ verticalSize: UIUserInterfaceSizeClass, _ horizontalSize: UIUserInterfaceSizeClass) -> Int = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
        switch (verticalSize, horizontalSize) {
        case (.compact, .regular): // iPhone5-6 portrait
            return 3
        case (.compact, .compact): // iPhone5-6 landscape
            return 5
        case (.regular, .regular): // iPad portrait/landscape
            return 7
        default:
            return 3
        }
    }
    
    var takePhotos: Bool = true
    
    var takeCaremra: Bool = false
    
    var takePhotoIcon: UIImage? = UIImage(named: "add_photo")
}
