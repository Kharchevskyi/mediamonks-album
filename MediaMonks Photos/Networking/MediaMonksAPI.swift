//
//  MediaMonksAPI.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/21/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol MediaMonksAPIType {
    func albums(request: AlbumsRequest) -> SignalProducer<[MediaMonksAlbum], APIError>
    func photos(request: PhotoRequest) -> SignalProducer<[MediaMonksPhoto], APIError>
}

final class MediaMonksAPI: MediaMonksAPIType {
    static var `default`: MediaMonksAPI = MediaMonksAPI(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)

    private let session: URLSession
    private let baseURL: URL

    init(baseURL: URL, session: URLSession = .shared) {
        self.session = session
        self.baseURL = baseURL
    }

    func albums(request: AlbumsRequest) -> SignalProducer<[MediaMonksAlbum], APIError> {
        return getDataFor(request: request)
            .attemptMap { data -> Result<[MediaMonksAlbum], APIError> in
                let decoder = JSONDecoder()
                do {
                    let albums = try decoder.decode(FailableDecodableArray<MediaMonksAlbum>.self, from: data).elements
                    return Result.success(albums)
                } catch {
                    return Result.failure(APIError.dataMapping)
                }
            }
    }

    func photos(request: PhotoRequest) -> SignalProducer<[MediaMonksPhoto], APIError> {
        return getDataFor(request: request)
            .attemptMap { data -> Result<[MediaMonksPhoto], APIError> in
                let decoder = JSONDecoder()
                do {
                    let photos = try decoder.decode(FailableDecodableArray<MediaMonksPhoto>.self, from: data).elements
                    return Result.success(photos)
                } catch {
                    return Result.failure(APIError.dataMapping)
                }
            }
    }

    private func getDataFor(request: MediaMonksApiRequest) -> SignalProducer<Data, APIError> {
        guard var components = URLComponents(string: baseURL.absoluteString) else {
            return SignalProducer(error: APIError.malformedBaseURL)
        }

        components.path = "/\(request.path)"

        guard let url = components.url else {
            return SignalProducer(error: APIError.malformedBaseURL)
        }

        return session.reactive
            .data(with: URLRequest(url: url))
            .mapError { APIError.request($0) }
            .map { $0.0 }
    }
}
