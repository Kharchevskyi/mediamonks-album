//
//  MosaicLayoutSectionGeometry.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class MosaicLayoutSectionGeometry {

    /// Layout content height (dynamically calculated)
    private(set) var contentHeight: CGFloat = 0

    /// Sections geometry information
    private let geometryInfo: MosaicLayoutSectionGeometryInfo

    /// Layout content width
    private let contentWidth: CGFloat

    init(geometryInfo: MosaicLayoutSectionGeometryInfo) {
        let columnsWidth = geometryInfo.columns.reduce(0) { return $0 + $1.width }
        let interitemSpacing = geometryInfo.minimumInteritemSpacing * CGFloat(geometryInfo.columns.count - 1)
        self.contentWidth = columnsWidth + interitemSpacing
        self.geometryInfo = geometryInfo
    }

    // MARK: - Interface
    func registerElement(with geometry: CGRect) {
        contentHeight = max(geometry.maxY, contentHeight - geometryInfo.sectionInset.bottom) + geometryInfo.sectionInset.bottom
    }

    func frameForItem(withMozaikSize size: MosaicLayoutSize, at position: MosaicLayoutPosition) -> CGRect {
        var width: CGFloat = 0.0
        for column in position.column...(position.column + size.columns - 1) {
            width += geometryInfo.columns[column].width
        }
        width += CGFloat(size.columns - 1) * geometryInfo.minimumInteritemSpacing
        let height = CGFloat(size.rows) * geometryInfo.rowHeight + CGFloat(size.rows - 1) * geometryInfo.minimumLineSpacing
        let xOffset = xOffsetForItem(at: position)
        let yOffset = yOffsetForItem(at: position)
        return CGRect(x: xOffset, y: yOffset, width: width, height: height)
    }

    func frameForSupplementaryView(of kind: String) -> CGRect? {
        if kind == UICollectionView.elementKindSectionFooter {
            return geometryInfo.footerHeight > 0 ? CGRect(x: geometryInfo.sectionInset.left, y: contentHeight - geometryInfo.sectionInset.bottom, width: contentWidth, height: geometryInfo.footerHeight) : nil
        } else if kind == UICollectionView.elementKindSectionHeader {
            return geometryInfo.headerHeight > 0 ? CGRect(x: geometryInfo.sectionInset.left, y: geometryInfo.sectionInset.top, width: contentWidth, height: geometryInfo.headerHeight) : nil
        }
        fatalError("Unknown supplementary view kind: \(kind)")
    }

    // MARK: - Helpers

    private func xOffsetForItem(at position: MosaicLayoutPosition) -> CGFloat {
        var xOffset: CGFloat = geometryInfo.sectionInset.left
        if position.column == 0 {
            return xOffset
        }
        for column in 0...position.column - 1 {
            xOffset += geometryInfo.columns[column].width + geometryInfo.minimumInteritemSpacing
        }
        return xOffset
    }

    private func yOffsetForItem(at position: MosaicLayoutPosition) -> CGFloat {
        return (geometryInfo.rowHeight + geometryInfo.minimumLineSpacing) * CGFloat(position.row) + geometryInfo.sectionInset.top + geometryInfo.headerHeight
    }
}
