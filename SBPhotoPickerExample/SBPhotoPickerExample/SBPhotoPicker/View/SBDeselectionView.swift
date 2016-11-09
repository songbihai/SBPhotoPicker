//
//  SBDeselectionView.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/2.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

@IBDesignable
class SBDeselectionView: UIView {
    
    var settings: SBPhotoPickerSettings = SBSettings()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let checkmarkFrame = bounds;
        
        let group = CGRect(x: checkmarkFrame.minX + 3, y: checkmarkFrame.minY + 3, width: checkmarkFrame.width - 6, height: checkmarkFrame.height - 6)
        let checkedOvalPath = UIBezierPath(ovalIn: CGRect(x: group.minX + floor(group.width * 0.0 + 0.5), y: group.minY + floor(group.height * 0.0 + 0.5), width: floor(group.width * 1.0 + 0.5) - floor(group.width * 0.0 + 0.5), height: floor(group.height * 1.0 + 0.5) - floor(group.height * 0.0 + 0.5)))
        settings.selectionStrokeColor.setStroke()
        checkedOvalPath.lineWidth = 1
        checkedOvalPath.stroke()
        
        context.setFillColor(UIColor.white.cgColor)
    }
}
