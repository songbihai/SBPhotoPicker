//
//  SBAlbumCell.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

final class SBAlbumCell: UITableViewCell {
    static let identifier: String = "kSBAlbumCell"

    var selectedCount: Int = 0 {
        didSet {
            guard selectedCount > 0 else {
                selectionView.isHidden = true
                return
            }
            selectionView.isHidden = false
            selectionView.selectionString = "\(selectedCount)"
        }
    }
    
    var albumTitleLabel: UILabel!
    var countLabel: UILabel!
    var firstImageView: UIImageView!
    var secondImageView: UIImageView!
    var thirdImageView: UIImageView!
    fileprivate var selectionView: SBSelectionView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                accessoryType = .checkmark
            } else {
                accessoryType = .none
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addAllSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    fileprivate func addAllSubviews() {
        let aplhaView = UIView()
        aplhaView.translatesAutoresizingMaskIntoConstraints = false
        aplhaView.backgroundColor = UIColor.clear
        contentView.addSubview(aplhaView)
        contentView.addConstraint(NSLayoutConstraint.init(item: aplhaView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: aplhaView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 8))
        contentView.addConstraint(NSLayoutConstraint.init(item: aplhaView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 84))
        contentView.addConstraint(NSLayoutConstraint.init(item: aplhaView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 84))
        
        thirdImageView = UIImageView()
        thirdImageView.contentMode = .scaleAspectFill
        thirdImageView.translatesAutoresizingMaskIntoConstraints = false
        thirdImageView.clipsToBounds = true
        aplhaView.addSubview(thirdImageView)
        aplhaView.addConstraint(NSLayoutConstraint.init(item: thirdImageView, attribute: .top, relatedBy: .equal, toItem: aplhaView, attribute: .top, multiplier: 1.0, constant: 0))
        aplhaView.addConstraint(NSLayoutConstraint.init(item: thirdImageView, attribute: .left, relatedBy: .equal, toItem: aplhaView, attribute: .left, multiplier: 1.0, constant: 0))
        aplhaView.addConstraint(NSLayoutConstraint.init(item: thirdImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 79))
        aplhaView.addConstraint(NSLayoutConstraint.init(item: thirdImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 79))
        
        secondImageView = UIImageView()
        secondImageView.contentMode = .scaleAspectFill
        secondImageView.translatesAutoresizingMaskIntoConstraints = false
        secondImageView.clipsToBounds = true
        aplhaView.addSubview(secondImageView)
        aplhaView.addConstraint(NSLayoutConstraint.init(item: secondImageView, attribute: .centerY, relatedBy: .equal, toItem: aplhaView, attribute: .centerY, multiplier: 1.0, constant: 0))
        aplhaView.addConstraint(NSLayoutConstraint.init(item: secondImageView, attribute: .centerX, relatedBy: .equal, toItem: aplhaView, attribute: .centerX, multiplier: 1.0, constant: 0))
        aplhaView.addConstraint(NSLayoutConstraint.init(item: secondImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 79))
        aplhaView.addConstraint(NSLayoutConstraint.init(item: secondImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 79))
        
        firstImageView = UIImageView()
        firstImageView.contentMode = .scaleAspectFill
        firstImageView.translatesAutoresizingMaskIntoConstraints = false
        firstImageView.clipsToBounds = true
        aplhaView.addSubview(firstImageView)
        aplhaView.addConstraint(NSLayoutConstraint.init(item: firstImageView, attribute: .right, relatedBy: .equal, toItem: aplhaView, attribute: .right, multiplier: 1.0, constant: 0))
        aplhaView.addConstraint(NSLayoutConstraint.init(item: firstImageView, attribute: .bottom, relatedBy: .equal, toItem: aplhaView, attribute: .bottom, multiplier: 1.0, constant: 0))
        aplhaView.addConstraint(NSLayoutConstraint.init(item: firstImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 79))
        aplhaView.addConstraint(NSLayoutConstraint.init(item: firstImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 79))
        
        for imageView in [firstImageView, secondImageView, thirdImageView] {
            imageView?.layer.shadowColor = UIColor.white.cgColor
            imageView?.layer.shadowRadius = 1.0
            imageView?.layer.shadowOffset = CGSize(width: 0.5, height: -0.5)
            imageView?.layer.shadowOpacity = 1.0
        }
        
        albumTitleLabel = UILabel()
        albumTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(albumTitleLabel)
        contentView.addConstraint(NSLayoutConstraint.init(item: albumTitleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: albumTitleLabel, attribute: .left, relatedBy: .equal, toItem: aplhaView, attribute: .right, multiplier: 1.0, constant: 8))
        
        countLabel = UILabel()
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.textColor = UIColor.lightGray
        contentView.addSubview(countLabel)
        contentView.addConstraint(NSLayoutConstraint.init(item: countLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: countLabel, attribute: .left, relatedBy: .equal, toItem: albumTitleLabel, attribute: .right, multiplier: 1.0, constant: 5))
        
        selectionView = SBSelectionView()
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        selectionView.settings.selectionTextAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12.0),
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: UIColor.white
        ]
        selectionView.backgroundColor = UIColor.clear
        selectionView.isHidden = true
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectionView)
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -15))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 25))
        contentView.addConstraint(NSLayoutConstraint.init(item: selectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 25))
    }

}
