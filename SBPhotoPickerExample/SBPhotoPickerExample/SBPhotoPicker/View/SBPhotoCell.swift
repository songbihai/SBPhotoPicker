//
//  SBPhotoCell.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

final class SBPhotoCell: UICollectionViewCell {
    static let identifier: String = "kSBPhotoCell"
    
    var selectedButtonClick: ((Bool) -> Void)?
    var selectedButton: UIButton!
    var imageView: UIImageView!
    
    fileprivate var selectionOverlayView: UIView!
    fileprivate var selectionView: SBSelectionView!
    fileprivate var deselectionView: SBDeselectionView!
    
    weak var photo: SBPhoto?
    
    var selectedPhoto: Bool = false {
        didSet(newValue) {
            let hasChanged = selectedPhoto != newValue
            if UIView.areAnimationsEnabled && hasChanged {
                UIView.animate(withDuration: TimeInterval(0.1), animations: { () -> Void in
                    self.updateAlpha(self.selectedPhoto)
                    self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }, completion: { (finished: Bool) -> Void in
                    UIView.animate(withDuration: TimeInterval(0.1), animations: { () -> Void in
                        self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        }, completion: nil)
                }) 
            } else {
                updateAlpha(selectedPhoto)
            }
        }
    }
    
    var settings: SBPhotoPickerSettings {
        get {
            return selectionView.settings
        }
        set {
            selectionView.settings = newValue
        }
    }
    
    var selectionString: String {
        get {
            return selectionView.selectionString
        }
        set {
            selectionView.selectionString = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addAllSubviews()
        addAllConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func addAllSubviews() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        
        selectionOverlayView = UIView()
        selectionOverlayView.translatesAutoresizingMaskIntoConstraints = false
        selectionOverlayView.alpha = 0.0
        selectionOverlayView.backgroundColor = UIColor.white
        contentView.addSubview(selectionOverlayView)
        
        selectionView = SBSelectionView()
        selectionView.alpha = 0.0
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        selectionView.backgroundColor = UIColor.clear
        contentView.addSubview(selectionView)
        
        deselectionView = SBDeselectionView()
        deselectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deselectionView)
        
        selectedButton = UIButton()
        selectedButton.addTarget(self, action: #selector(SBPhotoCell.selectedButtonAction(_:)), for: .touchUpInside)
        selectedButton.backgroundColor = UIColor.clear
        selectedButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectedButton)
    }
    
    fileprivate func addAllConstraints() {
        contentView.addConstraint(NSLayoutConstraint.init(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: imageView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: imageView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionOverlayView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionOverlayView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionOverlayView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionOverlayView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 5))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -5))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 25))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 25))
        
        contentView.addConstraint(NSLayoutConstraint.init(item: deselectionView, attribute: .top, relatedBy: .equal, toItem: selectionView, attribute: .top, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: deselectionView, attribute: .right, relatedBy: .equal, toItem: selectionView, attribute: .right, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: deselectionView, attribute: .width, relatedBy: .equal, toItem: selectionView, attribute: .width, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: deselectionView, attribute: .height, relatedBy: .equal, toItem: selectionView, attribute: .height, multiplier: 1.0, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint.init(item: selectedButton, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 5))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectedButton, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -5))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectedButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 35))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectedButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 35))
        
    }
    
    @objc fileprivate func selectedButtonAction(_ sender: UIButton) {
        selectedButtonClick?(selectedPhoto)
    }
    
    fileprivate func updateAlpha(_ selected: Bool) {
        if selectedPhoto == true {
            self.selectionView.alpha = 1.0
            self.selectionOverlayView.alpha = 0.3
        } else {
            self.selectionView.alpha = 0.0
            self.selectionOverlayView.alpha = 0.0
        }
    }
}
