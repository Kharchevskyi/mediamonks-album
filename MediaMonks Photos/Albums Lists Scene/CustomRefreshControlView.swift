//
//  CustomRefreshControlView.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class CustomRefreshControlView: UIView {
    var textColor: UIColor? {
        didSet {
            labels.forEach { $0.textColor = textColor }
        }
    }

    var font: UIFont? {
        didSet {
            labels.forEach { $0.font = font }
        }
    }

    private var labels: [UILabel] = []
    private var isAnimating = false
    private var currentColorIndex = 0
    private var currentLabelIndex = 0
    private weak var refreshControl: UIRefreshControl?

    override private init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(text: String, refreshControl: UIRefreshControl) {
        self.refreshControl = refreshControl
        super.init(frame: .zero)
        let arrangedViews = text.map { character -> UILabel in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = String(character)
            return label
        }
        labels = arrangedViews
        let stackView = UIStackView(arrangedSubviews: arrangedViews)
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        constrainToEdges(stackView)
    }

    private func nextColor() -> UIColor {
        var colorsArray: Array<UIColor> = labels.map { _ in return UIColor.random }

        if currentColorIndex == colorsArray.count {
            currentColorIndex = 0
        }

        let returnColor = colorsArray[currentColorIndex]
        currentColorIndex += 1

        return returnColor
    }

    func animate() {
        isAnimating = true

        UIView.animate(
            withDuration: 0.1,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                guard let label = self.labels[safe: self.currentLabelIndex] else { return }
                label.transform = CGAffineTransform(rotationAngle: CGFloat.pi / CGFloat(4))
                label.textColor = self.nextColor()
            }, completion: { _ in
                UIView.animate(
                    withDuration: 0.05,
                    delay: 0.0,
                    options: .curveLinear,
                    animations: {
                        guard let label = self.labels[safe: self.currentLabelIndex] else { return }
                        label.transform = CGAffineTransform.identity
                        label.textColor = self.textColor

                    }, completion: { _ in
                        self.currentLabelIndex += 1

                        if self.currentLabelIndex < self.labels.count {
                            self.animate()
                        } else {
                            self.animateNextStep()
                        }
                    })
                })
    }

    private func animateNextStep() {
        UIView.animate(
            withDuration: 0.35,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                self.labels.forEach {
                    $0.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                }
            }, completion: { _ in
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0.0,
                    options: .curveLinear,
                    animations: { () -> Void in
                        self.labels.forEach {
                            $0.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                        }
                    }, completion: { _ in
                        if self.refreshControl?.isRefreshing ?? false {
                            self.currentLabelIndex = 0
                            self.animate()
                        } else {
                            self.isAnimating = false
                            self.currentLabelIndex = 0
                            self.labels.forEach {
                                $0.textColor = self.textColor
                                $0.transform = .identity
                            }
                        }
                    })
        })
    }
}
