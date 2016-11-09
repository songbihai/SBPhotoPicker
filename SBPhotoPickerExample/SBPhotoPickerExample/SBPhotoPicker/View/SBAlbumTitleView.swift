//
//  SBAlbumTitleView.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

class SBAlbumTitleView: UIView {
    var albumButton: UIButton!
    var isSelected: Bool = false
    fileprivate var context = 0
    
    var albumTitle = "" {
        didSet {
            if let imageView = self.albumButton?.imageView, let titleLabel = self.albumButton?.titleLabel {
                albumButton?.setTitle(self.albumTitle, for: UIControlState.normal)
                
                titleLabel.text = self.albumTitle
                titleLabel.sizeToFit()
                
                albumButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView.bounds.size.width, bottom: 0, right: imageView.bounds.size.width)
                albumButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: titleLabel.bounds.size.width + 4, bottom: 0, right: -(titleLabel.bounds.size.width + 4))
            }
        }
    }
    
    var arrowDownImage: UIImage? {
        if self.isSelected {
            return UIImage(named: "arrow_down_selected")
        }else {
            return UIImage(named: "arrow_down_normal")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addAllSubviews()
        albumButton.setImage(arrowDownImage, for: UIControlState.normal)
    }
    
    fileprivate func addAllSubviews() {
        albumButton = UIButton(type: .system)
        albumButton.translatesAutoresizingMaskIntoConstraints = false
        albumButton.setTitleColor(UIView().tintColor, for: UIControlState.normal)
        addSubview(albumButton)
        
        addConstraint(NSLayoutConstraint.init(item: albumButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: albumButton, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 8))
        addConstraint(NSLayoutConstraint.init(item: albumButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint.init(item: albumButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -8))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
