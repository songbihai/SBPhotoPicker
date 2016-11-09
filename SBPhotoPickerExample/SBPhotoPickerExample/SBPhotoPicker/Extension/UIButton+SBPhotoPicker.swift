//
//  UIButton+SBAdd.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/2.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

extension UIButton {
    
    func sb_setTitleWithoutAnimation(_ title: String?, forState state: UIControlState) {
        
        let animationEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        
        self.setTitle(title, for: state)
        self.layoutIfNeeded()
        
        UIView.setAnimationsEnabled(animationEnabled)
        
    }
}
