//
//  ViewState.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/24/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import Foundation

enum ViewState<T: Equatable>: Equatable {
    case idle
    case loading(Loading)
    case failed(ErrorState)
    case loaded([T])

    enum Loading {
        case initial
        case new
    }

    enum ErrorState: Equatable {
        case retryable(String)
        case message(String)
    }
}
