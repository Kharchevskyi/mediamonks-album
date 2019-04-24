//
//  MosaicLayoutAttributes.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation
import UIKit

enum MosaicLayoutAttributesError: Error {
    case notAllSectionsPrepared
}

class MosaicLayoutAttributes {
    private(set) var layoutAttributesArray: [UICollectionViewLayoutAttributes] = []
    private(set) var unionRectsArray: [CGRect] = []
    private let mosaicLayoutUnionSize: Int = 20
    private let layoutCache: MosaicCollectionViewLayoutCache

    init(layoutCache: MosaicCollectionViewLayoutCache, layoutMatrixes: [MosaicLayoutSectionMatrix], layoutGeometries: [MosaicLayoutSectionGeometry]) throws {
        self.layoutCache = layoutCache
        self.layoutAttributesArray = try self.buildLayoutAttributesForLayoutGeometries(layoutGeometries, withLayoutMatrixes: layoutMatrixes)
        self.unionRectsArray = self.buildUnionRectsFromLayoutAttributes(self.layoutAttributesArray)
    }

    // MARK: - Interface

    func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = self.layoutAttributesArray[indexPath.item]
        return attribute
    }

    func layoutAttributesForElementsInRect(_ rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var resultAttributes: [UICollectionViewLayoutAttributes] = []
        let unionRectsCount = self.unionRectsArray.count
        var begin = 0
        var end = unionRectsCount

        for unionRectIndex in (0..<unionRectsCount) {
            if !rect.intersects(self.unionRectsArray[unionRectIndex]) {
                continue
            }
            begin = unionRectIndex * mosaicLayoutUnionSize
            break
        }

        for unionRectIndex in (0..<unionRectsCount).reversed() {
            if !rect.intersects(self.unionRectsArray[unionRectIndex]) {
                continue
            }
            end = min((unionRectIndex + 1) * mosaicLayoutUnionSize, self.layoutAttributesArray.count)
            break
        }

        for index in begin..<end {
            let attributes = self.layoutAttributesArray[index]
            if rect.intersects(attributes.frame) {
                resultAttributes.append(attributes)
            }
        }

        return resultAttributes
    }

    // MARK: - Helper

    private func buildLayoutAttributesForLayoutGeometries(_ layoutGeometries: [MosaicLayoutSectionGeometry], withLayoutMatrixes layoutMatrixes: [MosaicLayoutSectionMatrix]) throws -> [UICollectionViewLayoutAttributes] {
        guard let numberOfSections = layoutCache.numberOfSections(), layoutGeometries.count == numberOfSections && layoutMatrixes.count == numberOfSections else {
            throw MosaicLayoutAttributesError.notAllSectionsPrepared
        }
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        var layoutSectionGeometryOffsetY: CGFloat = 0
        for section in 0..<numberOfSections {
            guard let itemsCount = layoutCache.numberOfItemsInSection(section) else {
                throw MosaicLayoutAttributesError.notAllSectionsPrepared
            }
            let layoutGeometry = layoutGeometries[section]
            let layoutMatrix = layoutMatrixes[section]

            if let attributes = buildLayoutAttributesForSupplementaryView(of: UICollectionView.elementKindSectionHeader, in: section, geometry: layoutGeometry, additionalOffsetY: layoutSectionGeometryOffsetY) {
                allAttributes.append(attributes)
            }

            for item in 0..<itemsCount {
                let indexPath = IndexPath(item: item, section: section)
                do {
                    let attributes = try buildLayoutAttributesForItem(at: indexPath, geometry: layoutGeometry, matrix: layoutMatrix, additionalOffsetY: layoutSectionGeometryOffsetY)
                    allAttributes.append(attributes)
                }
                catch let error as CustomStringConvertible {
                    fatalError(error.description)
                }
            }

            if let attributes = buildLayoutAttributesForSupplementaryView(of: UICollectionView.elementKindSectionFooter, in: section, geometry: layoutGeometry, additionalOffsetY: layoutSectionGeometryOffsetY) {
                allAttributes.append(attributes)
            }

            layoutSectionGeometryOffsetY += layoutGeometry.contentHeight
        }
        return allAttributes
    }

    private func buildLayoutAttributesForSupplementaryView(of kind: String, in section: MosaicLayoutSection, geometry: MosaicLayoutSectionGeometry, additionalOffsetY: CGFloat) -> UICollectionViewLayoutAttributes? {
        guard let frame = geometry.frameForSupplementaryView(of: kind) else {
            return nil
        }
        let indexPath = IndexPath(item: 0, section: section)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind, with: indexPath)
        attributes.frame = CGRect(x: frame.origin.x, y: frame.origin.y + additionalOffsetY, width: frame.width, height: frame.height)
        geometry.registerElement(with: frame)
        return attributes
    }

    private func buildLayoutAttributesForItem(at indexPath: IndexPath, geometry: MosaicLayoutSectionGeometry, matrix: MosaicLayoutSectionMatrix, additionalOffsetY: CGFloat) throws -> UICollectionViewLayoutAttributes {
        let itemSize = layoutCache.mozaikSizeForItem(atIndexPath: indexPath)
        let itemPosition = try matrix.positionForItem(of: itemSize)
        let itemGeometryFrame = geometry.frameForItem(withMozaikSize: itemSize, at: itemPosition)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(x: itemGeometryFrame.origin.x, y: itemGeometryFrame.origin.y + additionalOffsetY, width: itemGeometryFrame.width, height: itemGeometryFrame.height)
        geometry.registerElement(with: itemGeometryFrame)
        try matrix.addItem(of: itemSize, at: itemPosition)
        return attributes

    }

    private func buildUnionRectsFromLayoutAttributes(_ attributes: [UICollectionViewLayoutAttributes]) -> [CGRect] {
        var index = 0
        var unionRectsArray: [CGRect] = []
        let itemsCount = attributes.count
        while index < itemsCount {
            let frame1 = attributes[index].frame
            index = min(index + mosaicLayoutUnionSize, itemsCount) - 1
            let frame2 = attributes[index].frame
            unionRectsArray.append(frame1.union(frame2))
            index += 1
        }
        return unionRectsArray
    }
}
