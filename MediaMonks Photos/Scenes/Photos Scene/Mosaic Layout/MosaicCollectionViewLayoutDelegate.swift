//
//  MosaicCollectionViewLayoutDelegate.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

public protocol MosaicCollectionViewLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, mosaicSizeForItemAt indexPath: IndexPath) -> MosaicLayoutSize
    func collectonView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, geometryInfoFor section: MosaicLayoutSection) -> MosaicLayoutSectionGeometryInfo
}
