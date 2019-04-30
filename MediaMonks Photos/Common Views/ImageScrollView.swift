//
//  ImageScrollView.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

final class ImageScrollView: UIScrollView {

    private(set) var zoomView: UIImageView!

    private lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap(_:)))
        zoomingTap.numberOfTapsRequired = 2

        return zoomingTap
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = .fast
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        centerImage()
    }
}

extension ImageScrollView {
    func setImage(with urlString: String?) {
        zoomView.loadImageAsync(with: urlString)
    }

    func display(_ image: UIImage) {
        zoomView?.removeFromSuperview()
        zoomView = nil

        zoomView = UIImageView(image: image)

        addSubview(zoomView)

        configureFor(image.size)
    }

    func configureFor(_ imageSize: CGSize) {
        contentSize = imageSize
        setMaxMinZoomScaleForCurrentBounds()
        zoomScale = minimumZoomScale

        zoomView.addGestureRecognizer(zoomingTap)
        zoomView.isUserInteractionEnabled = true
    }

    private func setMaxMinZoomScaleForCurrentBounds() {
        let boundsSize = bounds.size
        let imageSize = zoomView.bounds.size

        let xScale =  boundsSize.width  / imageSize.width
        let yScale = boundsSize.height / imageSize.height

        let minScale = min(xScale, yScale)

        var maxScale: CGFloat = 1.0

        if minScale < 0.1 {
            maxScale = 0.3
        }

        if minScale >= 0.1 && minScale < 0.5 {
            maxScale = 0.7
        }

        if minScale >= 0.5 {
            maxScale = max(1.0, minScale)
        }


        maximumZoomScale = max(maxScale, 5)
        minimumZoomScale = minScale
    }

    func centerImage() {
        let boundsSize = bounds.size
        var frameToCenter = zoomView?.frame ?? CGRect.zero

        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width)/2
        }
        else {
            frameToCenter.origin.x = 0
        }

        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height)/2
        }
        else {
            frameToCenter.origin.y = 0
        }

        zoomView?.frame = frameToCenter
    }

    private func pointToCenterAfterRotation() -> CGPoint {
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        return convert(boundsCenter, to: zoomView)
    }

    private func scaleToRestoreAfterRotation() -> CGFloat {
        var contentScale = zoomScale

        if contentScale <= minimumZoomScale + CGFloat.ulpOfOne {
            contentScale = 0
        }

        return contentScale
    }

    private func maximumContentOffset() -> CGPoint {
        return CGPoint(
            x: contentSize.width - bounds.size.width,
            y: contentSize.height - bounds.size.height
        )
    }

    private func minimumContentOffset() -> CGPoint {

        return CGPoint.zero
    }

    private func restoreCenterPoint(to oldCenter: CGPoint, oldScale: CGFloat) {
        zoomScale = min(maximumZoomScale, max(minimumZoomScale, oldScale))

        let boundsCenter = convert(oldCenter, from: zoomView)

        var offset = CGPoint(x: boundsCenter.x - bounds.size.width/2.0, y: boundsCenter.y - bounds.size.height/2.0)

        let maxOffset = maximumContentOffset()
        let minOffset = minimumContentOffset()
        offset.x = max(minOffset.x, min(maxOffset.x, offset.x))
        offset.y = max(minOffset.y, min(maxOffset.y, offset.y))
        contentOffset = offset
    }

}

//MARK: - Handle ZoomTap
extension ImageScrollView {

    @objc private func handleZoomingTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        zoom(to: location, animated: true)
    }

    private func zoom(to point: CGPoint, animated: Bool) {
        let currentScale = zoomScale
        let minScale = minimumZoomScale
        let maxScale = maximumZoomScale

        if (minScale == maxScale && minScale > 1) {
            return;
        }

        let toScale = maxScale
        let finalScale = (currentScale == minScale) ? toScale : minScale
        let rectToZoom = zoomRect(for: finalScale, withCenter: point)
        zoom(to: rectToZoom, animated: animated)
    }

    private func zoomRect(for scale: CGFloat, withCenter center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero

        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale

        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)

        return zoomRect
    }
}

//MARK: - UIScrollViewDelegate
extension ImageScrollView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
