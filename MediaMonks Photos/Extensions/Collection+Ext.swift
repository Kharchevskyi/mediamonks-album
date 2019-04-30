//
//  Collection+Ext.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/25/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index)
            ? self[index]
            : nil
    }
}

public extension MutableCollection {
    subscript (safe index: Index) -> Iterator.Element? {
        set {
            if indices.contains(index), let newValue = newValue {
                self[index] = newValue
            }
        }
        get {
            return indices.contains(index)
                ? self[index]
                : nil
        }
    }
}
