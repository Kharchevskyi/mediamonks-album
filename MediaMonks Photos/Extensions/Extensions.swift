//
//  Extensions.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

// MARK: - UIView

extension UIView {
    func constrainToEdges(_ subview: UIView, insets: UIEdgeInsets = .zero) {

        subview.translatesAutoresizingMaskIntoConstraints = false

        let topContraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: insets.top)

        let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: -insets.bottom)

        let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: insets.left)

        let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: -insets.right)

        addConstraints([
            topContraint,
            bottomConstraint,
            leadingContraint,
            trailingContraint])
    }
}


// MARK: - ReusableView

protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView { }

extension UICollectionViewCell: ReusableView { }

extension UICollectionView {

    func register<T: ReusableView>(cellType: T.Type = T.self, bundle: Bundle = Bundle.main) {
        let reuseIdentifier = cellType.defaultReuseIdentifier
        if bundle.path(forResource: reuseIdentifier, ofType: "nib") != nil {
            register(UINib(nibName: reuseIdentifier, bundle: bundle), forCellWithReuseIdentifier: reuseIdentifier)
        }
        else {
            register(cellType, forCellWithReuseIdentifier: reuseIdentifier)
        }
    }

    func dequeueReusableCell<T>(ofType cellType: T.Type = T.self, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        let reuseIdentifier = cellType.defaultReuseIdentifier
        guard let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(reuseIdentifier)")
        }
        return cell
    }
}

extension UITableView {

    func register<T: ReusableView>(cellType: T.Type = T.self, bundle: Bundle = Bundle.main) {
        let reuseIdentifier = cellType.defaultReuseIdentifier
        if bundle.path(forResource: reuseIdentifier, ofType: "nib") != nil {
            register(UINib(nibName: reuseIdentifier, bundle: bundle), forCellReuseIdentifier: reuseIdentifier)
        }
        else {
            register(cellType, forCellReuseIdentifier: reuseIdentifier)
        }
    }

    func dequeueReusableCell<T>(ofType cellType: T.Type = T.self, at indexPath: IndexPath) -> T where T: UITableViewCell {
        let reuseIdentifier = cellType.defaultReuseIdentifier
        guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(reuseIdentifier)")
        }
        return cell
    }
}

// MARK: - Safe subscript

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

// MARK: - UIColor
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    static var random: UIColor {
        return UIColor(
            red: .random(in: (0...255)),
            green: .random(in: (0...255)),
            blue: .random(in: (0...255))
        )
    }
}

// MARK: - String
extension String {
    func firstUppercased() -> String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
