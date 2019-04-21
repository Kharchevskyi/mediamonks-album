//
//  ApiError.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/21/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

enum APIError: Error {
    // data mapping error, pretty self-explanatory
    case dataMapping
    // any error occurred during the request sending
    case request(Error)
    case internalStatusCode(Int, String?)
    case malformedBaseURL
}
