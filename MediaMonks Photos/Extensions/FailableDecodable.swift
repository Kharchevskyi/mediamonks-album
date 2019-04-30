//
//  FailableDecodable.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

// MARK: - Decodable Element

// Container that contains either decoded value or nil instead
struct FailableDecodable<Base: Decodable>: Decodable {
    let base: Base?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        base = try? container.decode(Base.self)
    }
}

// MARK: - Decodable Array

// Container that contains only successfully decoded elements
struct FailableDecodableArray<Element: Decodable>: Decodable & Sequence {
    typealias Iterator = Array<Element>.Iterator

    let elements: [Element]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = [Element]()
        if let count = container.count {
            elements.reserveCapacity(count)
        }
        while !container.isAtEnd {
            if let element = try container.decode(FailableDecodable<Element>.self).base {
                elements.append(element)
            }
        }
        self.elements = elements
    }

    func makeIterator() -> FailableDecodableArray<Element>.Iterator {
        return elements.makeIterator()
    }
}
