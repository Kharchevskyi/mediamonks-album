//
//  MosaicLayoutSectionMatrix.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

enum MosaicLayoutSectionMatrixError: Error {
    case columnOutOfBounds
    case rowOutOfBounds
}

extension MosaicLayoutSectionMatrixError: CustomStringConvertible {
    var description: String {
        switch self {
        case .columnOutOfBounds:
            return "Invalid column. Out of bounds"

        case .rowOutOfBounds:
            return "Invalid row. Out of bounds"
        }
    }
}

class MosaicLayoutSectionMatrix {
    private var arrayRepresentation: [[Bool]] = []
    private var numberOfRows: Int = 0
    private var lastItemPositionOfSize: [MosaicLayoutSize: MosaicLayoutPosition] = [:]
    private var lastItemPosition: MosaicLayoutPosition?
    private let numberOfColumns: Int
    private let section: Int

    // MARK: - Interface
    init(numberOfColumns: Int, section: MosaicLayoutSection) {
        self.numberOfColumns = numberOfColumns
        self.section = section
        self.arrayRepresentation = self.buildInitialArrayRepresentation(numberOfColumns: numberOfColumns)
    }

    func addItem(of size: MosaicLayoutSize, at position: MosaicLayoutPosition) throws -> Void {
        let lastColumn = position.column + size.columns - 1
        guard lastColumn < arrayRepresentation.count else {
            throw MosaicLayoutSectionMatrixError.columnOutOfBounds
        }

        let lastRow = position.row + size.rows - 1
        guard lastRow < arrayRepresentation[lastColumn].count else {
            throw MosaicLayoutSectionMatrixError.rowOutOfBounds
        }

        for column in position.column...lastColumn {
            for row in position.row...lastRow {
                arrayRepresentation[column][row] = true
                lastItemPositionOfSize[size] = position
            }
        }
    }

    ///
    /// Calculates the first available position for the item with the given size
    /// It extends the matrix array representation if the current number of rows is not enough
    ///
    /// - Parameter size: size of the adding item
    ///
    /// - Returns: position of the item
    func positionForItem(of size: MosaicLayoutSize) throws -> MosaicLayoutPosition {
        let maximumColumn = numberOfColumns - size.columns
        if maximumColumn < 0 {
            throw MosaicLayoutSectionMatrixError.columnOutOfBounds
        }
        let startingRow = lastItemPositionOfSize[size]?.row ?? 0
        return self.positionForItem(of: size, startingFrom: startingRow, maximumPositionColumn: maximumColumn)
    }

    // MARK: - Helpers

    private func positionForItem(of size: MosaicLayoutSize, startingFrom startRow: Int, maximumPositionColumn maximumColumn: Int) -> MosaicLayoutPosition {
        for row in startRow...numberOfRows {
            for column in 0...maximumColumn {
                let possiblePosition = MosaicLayoutPosition(atColumn: column, atRow: row, inSection: section)
                var isPositionFree = false
                do {
                    isPositionFree = try self.isPositionFree(possiblePosition, forItemOf: size)
                } catch MosaicLayoutSectionMatrixError.rowOutOfBounds {
                    self.extendMatrix(by: size.rows)
                    return self.positionForItem(of: size, startingFrom: row, maximumPositionColumn: maximumColumn)
                } catch  {
                    print(error)
                }
                
                if isPositionFree {
                    return possiblePosition
                }
            }
        }
        return MosaicLayoutPosition(atColumn: 0, atRow: 0, inSection: section)
    }

    private func extendMatrix(by rowsCount: Int) {
        for column in 0..<numberOfColumns {
            var rows: [Bool] = arrayRepresentation[column]
            for _ in 0..<rowsCount {
                rows.append(false)
            }
            arrayRepresentation[column] = rows
            numberOfRows += rowsCount
        }
    }

    private func buildInitialArrayRepresentation(numberOfColumns: Int) -> [[Bool]] {
        var arrayRepresentation: [[Bool]] = []
        for _ in 0..<numberOfColumns {
            let rows: [Bool] = []
            arrayRepresentation.append(rows)
        }
        return arrayRepresentation
    }

    private func isPositionFree(_ position: MosaicLayoutPosition, forItemOf size: MosaicLayoutSize) throws -> Bool {
        let lastColumn = position.column + size.columns - 1
        guard lastColumn < arrayRepresentation.count else {
            throw MosaicLayoutSectionMatrixError.columnOutOfBounds
        }

        let lastRow = position.row + size.rows - 1
        guard lastRow < arrayRepresentation[lastColumn].count else {
            throw MosaicLayoutSectionMatrixError.rowOutOfBounds
        }

        for column in position.column...lastColumn {
            for row in position.row...lastRow {
                if arrayRepresentation[column][row] {
                    return false
                }
            }
        }

        return true
    }
}
