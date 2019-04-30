//
//  ReusableView+Ext.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/25/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

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
