//
//  SBSettings.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

class SBSettings: SBPhotoPickerSettings {
    
    /// 是否显示状态栏
    var fullscreen: Bool = false
    
    /// 最大选择数量
    var maxNumberOfSelections: Int = 9
    
    /// 选中的圆圈的颜色
    var selectionFillColor: UIColor = UIView().tintColor
    
    /// 选中的圆圈的外圈颜色
    var selectionStrokeColor: UIColor = UIColor.white
    
    /// 选中的阴影颜色
    var selectionShadowColor: UIColor = UIColor.black
    
    /// 选中数量数字的属性
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
    
    /// item之间的间距
    var itemSpacing: CGFloat = 2.0
    
    /// 根据SizeClass确定一行显示几个item
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
    
    /// 第一个cell是否显示拍照
    var takePhotos: Bool = true
    
    /// 第一个cell是否显示实时画面
    var takeCaremra: Bool = false
    
    /// 第一个cell是拍照的图片icon
    var takePhotoIcon: UIImage? = UIImage(named: "add_photo")
}
