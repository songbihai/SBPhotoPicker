//
//  AlbumTableViewDataSource.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit
import Photos

class SBAlbumTableViewDataSource: NSObject {
    let photoCollections: [SBPhotoCollection]
    
    init(photoCollections: [SBPhotoCollection]) {
        self.photoCollections = photoCollections
        super.init()
    }
    
}

extension SBAlbumTableViewDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoCollections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SBAlbumCell.identifier, for: indexPath) as! SBAlbumCell
        let cachingManager = PHCachingImageManager.default() as? PHCachingImageManager
        cachingManager?.allowsCachingHighQualityImages = false
        
        if indexPath.row < photoCollections.count {
            let album = photoCollections[indexPath.row]

            cell.albumTitleLabel.text = album.title
            cell.countLabel.text = "(\(album.count))"
            cell.selectedCount = album.selectedCount
            cell.selectionStyle = .none
            let imageSize = CGSize(width: 79, height: 79)
            let imageContentMode: PHImageContentMode = .aspectFill
            for idx in 0..<3 {
                if idx < album.count {
                    switch idx {
                    case 0:
                        PHCachingImageManager.default().requestImage(for: album[idx]!.asset!, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                            cell.firstImageView.image = result
                            cell.secondImageView.image = result
                            cell.thirdImageView.image = result
                        }
                    case 1:
                        PHCachingImageManager.default().requestImage(for: album[idx]!.asset!, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                            cell.secondImageView.image = result
                            cell.thirdImageView.image = result
                        }
                    case 2:
                        PHCachingImageManager.default().requestImage(for: album[idx]!.asset!, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                            cell.thirdImageView.image = result
                        }
                        
                    default:
                        break
                    }
                }
            }
        }
        
        return cell
    }
}
