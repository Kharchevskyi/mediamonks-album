//
//  UIColor+Ext.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

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

extension UIColor {
    static var main: UIColor {
        return UIColor.init(red: 34, green: 38, blue: 57)
    }

    static var monkBlue: UIColor {
        return UIColor.init(red: 82, green: 173, blue: 206)
    }

    static var monkGreen: UIColor {
        return UIColor.init(red: 70, green: 156, blue: 136)
    }

    static var monkYellow: UIColor {
        return UIColor.init(red: 220, green: 156, blue: 62)
    }

    static var monkGray: UIColor {
        return UIColor.init(red: 50, green: 55, blue: 70)
    }
}
