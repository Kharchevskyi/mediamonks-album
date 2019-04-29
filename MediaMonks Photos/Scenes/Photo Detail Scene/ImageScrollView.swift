//
//  ImageScrollView.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/29/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {

    var zoomView: UIImageView!

    lazy var zoomingTap: UITapGestureRecognizer = {
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
        self.centerImage()
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

        zoomView.addGestureRecognizer(self.zoomingTap)
        zoomView.isUserInteractionEnabled = true
    }

    func setMaxMinZoomScaleForCurrentBounds() {
        let boundsSize = self.bounds.size
        let imageSize = zoomView.bounds.size

        let xScale =  boundsSize.width / imageSize.width
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
        minimumZoomScale = min(minScale, 0.5)
    }

    func centerImage() {
        let boundsSize = self.bounds.size
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


    //MARK: - UIScrollView Delegate Methods

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.zoomView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    } 

    func maximumContentOffset() -> CGPoint {
        let contentSize = self.contentSize
        let boundSize = self.bounds.size
        return CGPoint(x: contentSize.width - boundSize.width, y: contentSize.height - boundSize.height)
    }

    func minimumContentOffset() -> CGPoint {

        return CGPoint.zero
    }

    func restoreCenterPoint(to oldCenter: CGPoint, oldScale: CGFloat) {

        self.zoomScale = min(self.maximumZoomScale, max(self.minimumZoomScale, oldScale))


        let boundsCenter = self.convert(oldCenter, from: zoomView)

        var offset = CGPoint(x: boundsCenter.x - self.bounds.size.width/2.0, y: boundsCenter.y - self.bounds.size.height/2.0)

        let maxOffset = self.maximumContentOffset()
        let minOffset = self.minimumContentOffset()
        offset.x = max(minOffset.x, min(maxOffset.x, offset.x))
        offset.y = max(minOffset.y, min(maxOffset.y, offset.y))
        self.contentOffset = offset
    }

    //MARK: - Handle ZoomTap

    @objc func handleZoomingTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        self.zoom(to: location, animated: true)
    }

    func zoom(to point: CGPoint, animated: Bool) {
        let currentScale = self.zoomScale
        let minScale = self.minimumZoomScale
        let maxScale = self.maximumZoomScale

        if (minScale == maxScale && minScale > 1) {
            return;
        }

        let toScale = maxScale
        let finalScale = (currentScale == minScale) ? toScale : minScale
        let zoomRect = self.zoomRect(for: finalScale, withCenter: point)
        self.zoom(to: zoomRect, animated: animated)
    }

    func zoomRect(for scale: CGFloat, withCenter center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = self.bounds

        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale

        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)

        return zoomRect
    } 
}
