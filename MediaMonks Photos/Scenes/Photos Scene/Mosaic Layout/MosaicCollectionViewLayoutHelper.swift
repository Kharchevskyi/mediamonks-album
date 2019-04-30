//
//  MosaicCollectionViewLayoutHelper.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public typealias MosaicLayoutSection = Int
public typealias MosaicLayoutPositionRow = Int
public typealias MosaicLayoutPositionColumn = Int
public typealias MosaicLayoutSizeRows = Int
public typealias MosaicLayoutSizeColumns = Int

public struct MosaicLayoutPosition {
    /// Column number of the item's position
    let column: MosaicLayoutPositionColumn
    /// Row number of the item's position
    let row: MosaicLayoutPositionRow
    /// Section number of the item's
    let section: MosaicLayoutSection

    public init(atColumn column: MosaicLayoutPositionRow, atRow row: MosaicLayoutPositionColumn, inSection section: MosaicLayoutSection) {
        self.column = column
        self.row = row
        self.section = section
    }
}

public struct MosaicLayoutSize {
    /// Columns number that item requires
    let columns: Int
    /// Rows number that item requires
    let rows: Int

    public init(numberOfColumns columns: Int, numberOfRows rows: Int) {
        self.columns = columns
        self.rows = rows
    }

    public func totalCells() -> Int {
        return columns * rows
    }
}

public struct MosaicLayoutColumn {
    let width: CGFloat
    public init(width: CGFloat) {
        self.width = width
    }
}

public struct MosaicLayoutSectionGeometryInfo {
    /// array of `MosaicLayoutColumn` for the layout
    let columns: [MosaicLayoutColumn]

    /// height for each row in points
    let rowHeight: CGFloat

    /// minimum space between items
    let minimumInteritemSpacing: CGFloat

    /// minimum space between each row
    let minimumLineSpacing: CGFloat

    /// Insets for the section from top, left, right, bottom
    let sectionInset: UIEdgeInsets

    /// Height for header in section
    /// Width is currently limited to the collection view width
    let headerHeight: CGFloat

    /// Height for footer in section
    /// Width is currently limited to the collection view width
    let footerHeight: CGFloat

    public init(rowHeight: CGFloat, columns: [MosaicLayoutColumn], minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = UIEdgeInsets.zero, headerHeight: CGFloat = 0, footerHeight: CGFloat = 0) {
        self.columns = columns
        self.rowHeight = rowHeight
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.sectionInset = sectionInset
        self.headerHeight = headerHeight
        self.footerHeight = footerHeight
    }

    /// Checks whether the geometry info is valid
    public func isValid() -> Bool {
        return columns.count > 0 && rowHeight > 0
    }
}

extension MosaicLayoutSize: Equatable, Hashable {
    public static func == (lhs: MosaicLayoutSize, rhs: MosaicLayoutSize) -> Bool {
        return lhs.columns == rhs.columns && lhs.rows == rhs.rows
    }

    public var hashValue: Int {
        return combineHashes([columns.hashValue, rows.hashValue, 0])
    }
}

extension MosaicLayoutPosition: Equatable, Hashable {
    public static func == (lhs: MosaicLayoutPosition, rhs: MosaicLayoutPosition) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row && lhs.section == rhs.section
    }

    public var hashValue: Int {
        return combineHashes([column.hashValue, row.hashValue, section.hashValue, 0])
    }
}

private func combineHashes(_ hashes: [Int]) -> Int {
    return hashes.reduce(0, combineHashValues)
}

private func combineHashValues(_ initial: Int, _ other: Int) -> Int {
    #if arch(x86_64) || arch(arm64)
    let magic: UInt = 0x9e3779b97f4a7c15
    #elseif arch(i386) || arch(arm)
    let magic: UInt = 0x9e3779b9
    #endif
    var lhs = UInt(bitPattern: initial)
    let rhs = UInt(bitPattern: other)
    lhs ^= rhs &+ magic &+ (lhs << 6) &+ (lhs >> 2)
    return Int(bitPattern: lhs)
}
