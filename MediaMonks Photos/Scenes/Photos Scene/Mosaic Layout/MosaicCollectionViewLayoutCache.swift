//
//  MosaicCollectionViewLayoutCache.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation
import UIKit

class MosaicCollectionViewLayoutCache {
    private var cachedNumberOfSections: Int?
    private var cachedNumberOfItemsInSectionDictionary: [Int: Int]
    private var cachedSizeOfItemAtIndexPathDictionary: [IndexPath: MosaicLayoutSize]
    private let collectionView: UICollectionView
    private weak var mosaicLayoutDelegate: MosaicCollectionViewLayoutDelegate?

    init(collectionView: UICollectionView, mosaicLayoutDelegate: MosaicCollectionViewLayoutDelegate) {
        self.collectionView = collectionView
        self.mosaicLayoutDelegate = mosaicLayoutDelegate
        self.cachedNumberOfItemsInSectionDictionary = [:]
        self.cachedSizeOfItemAtIndexPathDictionary = [:]
    }

    func numberOfItemsInSection(_ section: Int) -> Int? {
        if cachedNumberOfItemsInSectionDictionary[section] == nil {
            cachedNumberOfItemsInSectionDictionary[section] = collectionView.numberOfItems(inSection: section)
        }

        return cachedNumberOfItemsInSectionDictionary[section]
    }

    func numberOfSections() -> Int? {
        if cachedNumberOfSections == nil {
            cachedNumberOfSections = collectionView.numberOfSections
        }
        
        return cachedNumberOfSections
    }

    func mozaikSizeForItem(atIndexPath indexPath: IndexPath) -> MosaicLayoutSize {
        guard let delegate = mosaicLayoutDelegate else {
            fatalError("MosaicLayoutCache must have delegate")
        }
        guard let layout = collectionView.collectionViewLayout as? MosaicCollectionViewLayout else {
            fatalError("collectionView must have a layout")
        }
        if let size = cachedSizeOfItemAtIndexPathDictionary[indexPath] {
            return size
        }
        return delegate.collectionView(collectionView, layout: layout, mosaicSizeForItemAt: indexPath)
    }
}
