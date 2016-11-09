//
//  SBCameraCollectionViewDataSource.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 2016/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

final class SBCameraCollectionViewDataSource: NSObject {
    let cameraAvailable: Bool
    let settings: SBPhotoPickerSettings
    
    init(settings: SBPhotoPickerSettings, cameraAvailable: Bool) {
        self.settings = settings
        self.cameraAvailable = cameraAvailable
        super.init()
    }
}

extension SBCameraCollectionViewDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if cameraAvailable && settings.takePhotos {
            return 1
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if cameraAvailable && settings.takePhotos {
            return 1
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cameraCell = collectionView.dequeueReusableCell(withReuseIdentifier: SBCameraCell.identifier, for: indexPath) as! SBCameraCell
        cameraCell.accessibilityIdentifier = "camera_cell_\(indexPath.item)"
        cameraCell.takePhotoIcon = settings.takePhotoIcon
        
        return cameraCell
    }
}
