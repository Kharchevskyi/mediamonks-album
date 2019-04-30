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

extension ViewState {
    var cellsCount: Int {
        switch self {
        case .idle: return 0
        case .loading(.initial):  return 1 // provide a cell for loading state
        case .loading(.new):      return 0
        case .failed(.retryable): return 1 // provide a cell for retry state.
        case .failed(.message):   return 0
        case .loaded(let items):  return items.count // provide a cell for every album.
        }
    }

    var items: [T] {
        switch self {
        case .loaded(let items): return items
        default: return []
        }
    }
}
