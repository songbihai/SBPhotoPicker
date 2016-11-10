//
//  NSIndexSet+SBAdd.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

public extension IndexSet {
    public func sb_indexPathsForSection(_ section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for (index, _) in enumerated() {
            indexPaths.append(IndexPath(item: index, section: section))
        }
        return indexPaths
    }
}
