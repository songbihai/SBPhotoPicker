//
//  SBCollectionViewLayout.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//  https://github.com/mikaoj/BSGridCollectionViewLayout

import UIKit

public final class SBCollectionViewLayout: UICollectionViewLayout {

    public var itemSpacing: CGFloat = 0 {
        didSet {
            itemSize = estimatedItemSize()
        }
    }

    public var itemsPerRow = 3 {
        didSet {
            itemSize = estimatedItemSize()
        }
    }

    public var itemHeightRatio: CGFloat = 1 {
        didSet {
            itemSize = estimatedItemSize()
        }
    }

    public fileprivate(set) var itemSize = CGSize.zero

    var items = 0
    var rows = 0

    public override func prepare() {
        items = estimatedNumberOfItems()
        rows = items / itemsPerRow + ((items % itemsPerRow > 0) ? 1 : 0)

        itemSize = estimatedItemSize()
    }

    public override var collectionViewContentSize : CGSize {
        guard let collectionView = collectionView, rows > 0 else {
            return CGSize.zero
        }
        
        let height = estimatedRowHeight() * CGFloat(rows)
        return CGSize(width: collectionView.bounds.width, height: height)
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return indexPathsInRect(rect).map { (indexPath) -> UICollectionViewLayoutAttributes? in
            return self.layoutAttributesForItem(at: indexPath)
        }.flatMap { $0 }
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.row >= 0 && indexPath.section >= 0 else {
            return nil
        }
        
        let itemIndex = flatIndex(indexPath)
        let rowIndex = itemIndex % itemsPerRow
        let row = itemIndex / itemsPerRow

        let x = (CGFloat(rowIndex) * itemSpacing) + (CGFloat(rowIndex) * itemSize.width)
        let y = (CGFloat(row) * itemSpacing) + (CGFloat(row) * itemSize.height)
        let width = itemSize.width
        let height = itemSize.height

        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attribute.frame = CGRect(x: x, y: y, width: width, height: height)

        return attribute
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    public override func layoutAttributesForDecorationView(ofKind kind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }

    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at atIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }
}

extension SBCollectionViewLayout {

    func indexPathsInRect(_ rect: CGRect) -> [IndexPath] {
        guard items > 0 && rows > 0 else { return [] }
        
        let rowHeight = estimatedRowHeight()
        
        let startRow = SBCollectionViewLayout.firstRowInRect(rect, withRowHeight: rowHeight)
        let endRow = SBCollectionViewLayout.lastRowInRect(rect, withRowHeight: rowHeight, max: rows)
        guard startRow <= endRow else { return [] }
        
        let startIndex = SBCollectionViewLayout.firstIndexInRow(min(startRow, endRow), withItemsPerRow: itemsPerRow)
        let endIndex = SBCollectionViewLayout.lastIndexInRow(max(startRow, endRow), withItemsPerRow: itemsPerRow, numberOfItems: items)
        
        guard startIndex <= endIndex else { return [] }
        let indexPaths = (startIndex...endIndex).map { indexPathFromFlatIndex($0) }

        return indexPaths
    }

    static func firstRowInRect(_ rect: CGRect, withRowHeight rowHeight: CGFloat) -> Int {
        if rect.origin.y / rowHeight < 0 {
            return 0
        } else {
            return Int(rect.origin.y / rowHeight)
        }
    }

    static func lastRowInRect(_ rect: CGRect, withRowHeight rowHeight: CGFloat, max: Int) -> Int {
        guard rect.size.height >= rowHeight else { return 0 }
        
        if (rect.origin.y + rect.height) / rowHeight > CGFloat(max) {
            return max - 1
        } else {
            return Int(ceil((rect.origin.y + rect.height) / rowHeight)) - 1
        }
    }

    static func firstIndexInRow(_ row: Int, withItemsPerRow itemsPerRow: Int) -> Int {
        return row * itemsPerRow
    }

    static func lastIndexInRow(_ row: Int, withItemsPerRow itemsPerRow: Int, numberOfItems: Int) -> Int {
        let maxIndex = (row + 1) * itemsPerRow - 1
        let bounds = numberOfItems - 1
        
        if maxIndex > bounds {
            return bounds
        } else {
            return maxIndex
        }
    }

    func flatIndex(_ indexPath: IndexPath) -> Int {
        guard let collectionView = collectionView else {
            return 0
        }
        
        return (0..<(indexPath as IndexPath).section).reduce((indexPath as IndexPath).row) { $0 + collectionView.numberOfItems(inSection: $1)}
    }

    func indexPathFromFlatIndex(_ index: Int) -> IndexPath {
        guard let collectionView = collectionView else {
            return IndexPath(item: 0, section: 0)
        }

        var item = index
        var section = 0

        while(item >= collectionView.numberOfItems(inSection: section)) {
            item -= collectionView.numberOfItems(inSection: section)
            section += 1
        }

        return IndexPath(item: item, section: section)
    }

    func estimatedItemSize() -> CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }

        let itemWidth = (collectionView.bounds.width - CGFloat(itemsPerRow - 1) * itemSpacing) / CGFloat(itemsPerRow)
        return CGSize(width: itemWidth, height: itemWidth * itemHeightRatio)
    }

    func estimatedNumberOfItems() -> Int {
        guard let collectionView = collectionView else {
            return 0
        }
        
        return (0..<collectionView.numberOfSections).reduce(0, {$0 + collectionView.numberOfItems(inSection: $1)})
    }

    func estimatedRowHeight() -> CGFloat {
        return itemSize.height+itemSpacing
    }
}
