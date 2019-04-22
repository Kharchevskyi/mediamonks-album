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
    case malformedBaseURL
}

extension APIError {
    func userDescription() -> String? {
        switch self {
        case .dataMapping: return "Oooops, something went wrong."
        case .request: return "Oooops, we've got server problems."
        case .malformedBaseURL: print("Warning, check networking"); return nil
        }
    }
}
