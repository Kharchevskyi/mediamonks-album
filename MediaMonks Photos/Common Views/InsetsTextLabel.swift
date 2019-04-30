//
//  InsetsTextLabel.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

@IBDesignable
final class InsetsTextLabel: UILabel {
    override class var layerClass : AnyClass {
        return CAGradientLayer.self
    }

    @IBInspectable var textInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width + textInsets.left + textInsets.right,
                      height: super.intrinsicContentSize.height + textInsets.top + textInsets.bottom
        )
    }
}
