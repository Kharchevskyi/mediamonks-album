//
//  UIImageView+Ext.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/25/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

extension UIImageView {
    private static var taskKey = 0
    private static var urlKey = 0

    private var currentTask: URLSessionTask? {
        get { return objc_getAssociatedObject(self, &UIImageView.taskKey) as? URLSessionTask }
        set { objc_setAssociatedObject(self, &UIImageView.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var currentURL: URL? {
        get { return objc_getAssociatedObject(self, &UIImageView.urlKey) as? URL }
        set { objc_setAssociatedObject(self, &UIImageView.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func loadImageAsync(with urlString: String?) {
        weak var oldTask = currentTask
        currentTask = nil
        oldTask?.cancel()

        self.image = nil

        guard let urlString = urlString else { return }
        if let cachedImage = ImageCacheImpl.shared.image(forKey: urlString) {
            self.image = cachedImage
            return
        }

        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.startAnimating()
        addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])

        let url = URL(string: urlString)!
        currentURL = url
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            self?.currentTask = nil

            if let error = error {
                if (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorCancelled {
                    return
                }
                DispatchQueue.main.async {
                    activityIndicator.removeFromSuperview()
                }

                print(error)
                return
            }

            guard let data = data, let downloadedImage = UIImage(data: data) else {
                DispatchQueue.main.async {
                    activityIndicator.removeFromSuperview()
                }
                print("unable to extract image")
                return
            }

            ImageCacheImpl.shared.save(image: downloadedImage, forKey: urlString)

            if url == self?.currentURL {
                DispatchQueue.main.async {
                    activityIndicator.removeFromSuperview()
                    self?.image = downloadedImage
                }
            }
        }

        currentTask = task
        task.resume()
    }

    func cancelDownloading() {
        currentTask?.cancel()
        currentURL = nil
    }
}
