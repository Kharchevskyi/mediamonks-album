//
//  PhotoFilter.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/30/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

enum PhotoFilter: CaseIterable {
    case original, simple, halftone

    var title: String {
        switch self {
        case .original: return "Original"
        case .simple: return "Simple blur"
        case .halftone: return "Halftone"
        }
    }

    func applyFilter(with image: UIImage) -> SignalProducer<(UIImage, PhotoFilter), NoError> {
        return SignalProducer { observer, lifetime in
            QueueScheduler(qos: .utility,name: "com.MediaMonks.Filter.queue")
                .schedule {
                    let value: UIImage

                    switch self {
                    case .original: value = image
                    case .simple:   value = self.simpleBlurFilter(inputImage: image)
                    case .halftone: value = self.halphtoneFilter(inputImage: image)
                    }

                    observer.send(value: (value, self))
                    observer.sendCompleted()
            }
        }
    }

    static func allFilteredImages(with image: UIImage) -> SignalProducer<[(UIImage, PhotoFilter)], NoError> {
        return SignalProducer(allCases)
            .flatMap(.concat) {
                $0.applyFilter(with: image)
            }
            .collect()
    }
}

extension PhotoFilter {
    private func halphtoneFilter(inputImage: UIImage) -> UIImage {
        guard let inputCIImage = CIImage(image: inputImage) else { return inputImage }

        let filter = CIFilter(name: "CICMYKHalftone")!
        filter.setValue(inputCIImage, forKey: kCIInputImageKey)
        filter.setValue(25, forKey: kCIInputWidthKey)

        guard let outputImage = filter.outputImage else { return inputImage }
        return UIImage(ciImage: outputImage)
    }

    private func simpleBlurFilter(inputImage: UIImage) -> UIImage {
        guard let inputCIImage = CIImage(image: inputImage) else { return inputImage }
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
        blurFilter.setValue(8, forKey: kCIInputRadiusKey)

        guard let outputImage = blurFilter.outputImage else { return inputImage }
        return UIImage(ciImage: outputImage)
    }
}
