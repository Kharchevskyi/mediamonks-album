//
//  MosaicCollectionViewLayout.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

public class MosaicCollectionViewLayout: UICollectionViewFlowLayout {
    weak var delegate: MosaicCollectionViewLayoutDelegate!
    open override var minimumLineSpacing: CGFloat {
        willSet {
            fatalError("MosaicLayout doesn't support setting minimumLineSpacing directly for layout. Please use MosaicLayoutDelegate method to return geometry info")
        }
    }

    open override var minimumInteritemSpacing: CGFloat {
        willSet {
            fatalError("MosaicLayout doesn't support setting minimumInteritemSpacing directly for layout. Please use MosaicLayoutDelegate method to return geometry info")
        }
    }


    /// Layout geometries array for each section
    private var layoutGeometries: [MosaicLayoutSectionGeometry]?

    /// Array of `MosaicLayoutSectionMatrix` objects that represents layout for each section
    private var layoutMatrixes: [MosaicLayoutSectionMatrix]?

    /// Current layout cache to speed up calculations
    private var layoutCache: MosaicCollectionViewLayoutCache?

    /// Keeps information about current layout attributes
    fileprivate var layoutAttributes: MosaicLayoutAttributes?

    /// Keeps information about current layout bounds size
    fileprivate var currentLayoutBounds: CGSize = CGSize.zero

    public init(delegate: MosaicCollectionViewLayoutDelegate) {
        self.delegate = delegate
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - UICollectionViewLayout

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return self.currentLayoutBounds != newBounds.size
    }

    open override func invalidateLayout() {
        super.invalidateLayout()
        resetLayout()
    }

    open override func prepare() {
        guard let collectionView = self.collectionView else {
            fatalError("self.collectionView expected to be not nil when execute prepareLayout()")
        }

        guard delegate != nil else {
            fatalError("self.delegate expected to be not nil when execute prepareLayout()")
        }
        super.prepare()

        if isLayoutReady() {
            return
        }

        currentLayoutBounds = collectionView.bounds.size
        layoutCache = MosaicCollectionViewLayoutCache(collectionView: collectionView, mosaicLayoutDelegate: delegate)
        if layoutCache?.numberOfSections() == 0 {
            return
        }

        createSectionInformations()
        guard let layoutCache = layoutCache, let layoutMatrixes = layoutMatrixes, let layoutGeometries = layoutGeometries else {
            fatalError("layout is not prepared, because of internal setup error")
        }
        do {
            layoutAttributes = try MosaicLayoutAttributes(layoutCache: layoutCache, layoutMatrixes: layoutMatrixes, layoutGeometries: layoutGeometries)
        } catch let error {
            fatalError("Internal layout attributes error: \(error)")
        }
    }

    open override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            fatalError("collectionView expected to be not nil when execute collectionViewContentSize()")
        }
        guard let layoutGeometries = layoutGeometries, let layoutCache = layoutCache else {
            return CGSize.zero
        }

        let numberOfSections = layoutCache.numberOfSections()
        if numberOfSections == 0 {
            return CGSize.zero
        }
        let contentSize = super.collectionViewContentSize
        let delta = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        let layoutGeometriesContentHeight = layoutGeometries.reduce(0) { result, geometry in
            return result + geometry.contentHeight
        }
        return CGSize(width: contentSize.width, height: max(layoutGeometriesContentHeight, delta))
    }

    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes?.layoutAttributesForItem(at: indexPath)
    }

    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }

    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes?.layoutAttributesForElementsInRect(rect)
    }

    // MARK: - Helpers

    private func isLayoutReady() -> Bool {
        return layoutCache != nil && layoutGeometries != nil && layoutMatrixes != nil && layoutAttributes != nil
    }

    private func resetLayout() {
        layoutAttributes = nil
        layoutCache = nil
        layoutMatrixes = nil
        layoutGeometries = nil
    }

    fileprivate func createSectionInformations() {
        guard let cache = layoutCache, let numberOfSection = cache.numberOfSections(), let delegate = self.delegate, let collectionView = collectionView else { return }
        var buildingLayoutGeometries: [MosaicLayoutSectionGeometry] = []
        var buildingLayoutMatrixes: [MosaicLayoutSectionMatrix] = []
        for section in 0..<numberOfSection {
            let sectionGeometryInfo = delegate.collectonView(collectionView, layout: self, geometryInfoFor: section)
            let sectionGeometry = MosaicLayoutSectionGeometry(geometryInfo: sectionGeometryInfo)
            buildingLayoutGeometries.append(sectionGeometry)
            let sectionMatrix = MosaicLayoutSectionMatrix(numberOfColumns: sectionGeometryInfo.columns.count, section: section)
            buildingLayoutMatrixes.append(sectionMatrix)
        }
        self.layoutGeometries = buildingLayoutGeometries
        self.layoutMatrixes = buildingLayoutMatrixes
    }
}
