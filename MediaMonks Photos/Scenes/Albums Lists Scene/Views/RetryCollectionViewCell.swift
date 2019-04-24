//
//  RetryCollectionViewCell.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

class RetryCollectionViewCell: UICollectionViewCell {
    typealias TapCallback = () -> Void
    enum LocalConstants {
        static let imageSize = CGSize(width: 69, height: 69)
    }

    private let retryView = UIView(frame: .zero)
    private let retryLabel = UILabel(frame: .zero)
    let retryImageView = UIImageView(image: #imageLiteral(resourceName: "monk_icon"))
    private var onTap: TapCallback?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        [retryImageView, retryLabel, retryView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = true
            $0.alpha = 1
        }

        NSLayoutConstraint.activate([
            retryView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            retryView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -LocalConstants.imageSize.height),
            retryView.widthAnchor.constraint(equalToConstant: LocalConstants.imageSize.width),
            retryView.heightAnchor.constraint(equalToConstant: LocalConstants.imageSize.height),
            retryImageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            retryImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -LocalConstants.imageSize.height),
            retryImageView.widthAnchor.constraint(equalToConstant: LocalConstants.imageSize.width),
            retryImageView.heightAnchor.constraint(equalToConstant: LocalConstants.imageSize.height),
            retryLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            retryLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            retryLabel.topAnchor.constraint(equalTo: retryImageView.bottomAnchor, constant: 16),
            retryLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0)
            ])

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        retryView.addGestureRecognizer(tapGestureRecognizer)
    }

    func setup(with message: String, subtitle: String = "Tap to retry", onTap block: TapCallback?) -> RetryCollectionViewCell {
        self.onTap = block
        UIView.animate(withDuration: 0.2) {
            [self.retryImageView, self.retryLabel, self.retryView]
                .forEach { $0.alpha = 1 }
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let titleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.paragraphStyle: paragraph
        ]
        let subTitleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.paragraphStyle: paragraph
        ]
        let title = NSMutableAttributedString(string: message , attributes: titleAttributes)
        title.append(NSAttributedString(string: "\n"))
        let subTitle = NSAttributedString(string: subtitle, attributes: subTitleAttributes)
        title.append(subTitle)
        retryLabel.numberOfLines = 0
        retryLabel.attributedText = title

        startAnimation()

        return self
    }

    func startAnimation() {
        UIView.animate(
            withDuration: 1.5,
            delay: 0.1,
            options: UIView.AnimationOptions.allowUserInteraction,
            animations: {
                self.retryImageView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }, completion: { _ in
            UIView.animate(
                withDuration: 1.5,
                animations: {
                    self.retryImageView.transform = .identity
            }, completion: { _ in
                self.startAnimation()
            })
        })
    }
}

extension RetryCollectionViewCell {
    private func pathAnimation(_ frame: CGRect) -> CAKeyframeAnimation {
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.duration = 3
        pathAnimation.path = zigzagPath(frame).cgPath
        pathAnimation.fillMode = .forwards
        pathAnimation.isRemovedOnCompletion = false
        return pathAnimation
    }

    private func zigzagPath(_ frame: CGRect) -> UIBezierPath {
        let zigzagPath = UIBezierPath()
        let ox = frame.origin.x
        let oy = frame.origin.y
        let ex = ox
        let ey = oy - CGFloat.random(in: ((center.y-100)...center.y))
        let t: CGFloat = CGFloat.random(in: (40...100))
        let controlPoint1 = CGPoint(x: ox - t, y: (oy + ey) / 2)
        let controlPoint2 = CGPoint(x: ox + t, y: controlPoint1.y)
        zigzagPath.move(to: CGPoint(x: ox, y: oy))

        zigzagPath.addCurve(
            to: CGPoint(x: ex, y: ey),
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2
        )
        return zigzagPath
    }

    @objc private func handleImageTap() {
        TapTicFeedback.generate(.light)
        animateRetryTap()
        onTap?()
    }

    private func animateRetryTap() {
        (10...Int.random(in: (20...30)))
            .forEach { tag in
                let imageView = UIImageView(image: #imageLiteral(resourceName: "photo_icon"))
                let sizeDimension = CGFloat.random(in: (20...30))

                window?.rootViewController?.view.addSubview(imageView)

                imageView.frame = CGRect(
                    x: self.retryImageView.frame.midX + CGFloat.random(in: (-150...150)),
                    y: self.retryImageView.frame.origin.y + CGFloat.random(in: (-20...40)),
                    width: sizeDimension,
                    height: sizeDimension
                )
                imageView.layer.add(pathAnimation(imageView.frame), forKey: "pathAnimation\(tag)")

                CATransaction.begin()

                CATransaction.setCompletionBlock {
                    UIView.transition(
                        with: imageView,
                        duration: 0.1,
                        options: .curveEaseInOut,
                        animations: {
                            imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    }, completion: { _ in
                        imageView.removeFromSuperview()
                    })
                }
        }
    }

    private func hideRetryState() {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                [self.retryImageView, self.retryLabel, self.retryView]
                    .forEach {
                        $0.alpha = 0
                }
        }, completion: nil)
    }
}
