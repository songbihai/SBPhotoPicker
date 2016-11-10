//
//  SBComposedCollectionViewDataSource.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 2016/11/9.
//  Copyright © 2016年 songbihai. All rights reserved.
//  处理第一个是不是拍照的逻辑更方便

import UIKit

final class SBComposedCollectionViewDataSource: NSObject {
    let dataSources: [UICollectionViewDataSource]
    
    init(dataSources: [UICollectionViewDataSource]) {
        self.dataSources = dataSources
        
        super.init()
    }
}

extension SBComposedCollectionViewDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources[section].collectionView(collectionView, numberOfItemsInSection: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSources[indexPath.section].collectionView(collectionView, cellForItemAt: IndexPath.init(item: indexPath.item, section: 0))
    }
}
