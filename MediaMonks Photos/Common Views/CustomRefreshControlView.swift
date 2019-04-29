//
//  CustomRefreshControlView.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class CustomRefreshControl {
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

    init(text: String, refreshControl: UIRefreshControl) {
        self.refreshControl = refreshControl

        let arrangedViews = text.map { character -> UILabel in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = String(character)
            label.font = UIFont.boldSystemFont(ofSize: 25)
            label.adjustsFontSizeToFitWidth = true
            return label
        }
        labels = arrangedViews
        let stackView = UIStackView(arrangedSubviews: arrangedViews)
        stackView.distribution = .equalSpacing

        refreshControl.addSubview(stackView)
        refreshControl.constrainToEdges(stackView, insets: UIEdgeInsets(top: 4, left: 32, bottom: 4, right: 32))
        refreshControl.tintColor = .clear
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

    private func animateNextStep() {
        UIView.animate(
            withDuration: 0.3,
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

    func animate() {
        isAnimating = true
        refreshControl?.beginRefreshing()

        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                guard let label = self.labels[safe: self.currentLabelIndex] else { return }
                label.transform = CGAffineTransform(rotationAngle: CGFloat.pi / CGFloat(4))
                label.textColor = self.nextColor()
            }, completion: { _ in
                UIView.animate(
                    withDuration: 0.1,
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

    func stopAnimating() {
        isAnimating = false
        labels.forEach {
            $0.textColor = self.textColor
            $0.transform = .identity
        }
        refreshControl?.endRefreshing()
    }

}
