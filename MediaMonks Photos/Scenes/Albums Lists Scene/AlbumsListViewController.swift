//
//  AlbumsListViewController.swift
//  MediaMonks Photos
//
//  Created by Anton Kharchevskyi on 4/22/19.
//  Copyright © 2019 Anton Kharchevskyi. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol AlbumsListViewControllerInput {
    func handle(state: ViewState<MediaMonksAlbumViewModel>)
}

protocol AlbumsListViewControllerOutput {
    func handle(action: AlbumsListInteractor.Action)
}

// MARK: - Implementation

final class AlbumsListViewController: UIViewController {

    var output: AlbumsListViewControllerOutput?
    private var state: ViewState<MediaMonksAlbumViewModel> = .idle {
        didSet {
//            print(state)
        }
    }

    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private let collectionViewLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )
    private lazy var activityView = CustomRefreshControl(
        text: "Media Monks",
        refreshControl: refreshControl
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        output?.handle(action: .setup)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        output?.handle(action: .dispose)
    }

    private func setupUI() {
        view.backgroundColor = .black

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: AlbumCell.self)
        collectionView.register(cellType: RetryCollectionViewCell.self)
        collectionView.addSubview(refreshControl)
        view.addSubview(collectionView)
        view.constrainToEdges(collectionView)

        activityView.textColor = .white
        activityView.font = UIFont.boldSystemFont(ofSize: 16)
    }

    @objc private func reload() {
        output?.handle(action: .loadNew)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension AlbumsListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return state.cellsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch state {
        case .loaded(let items):
            guard let viewModel = items[safe: indexPath.row] else {
                fatalError("no cell provided")
            }
            return collectionView.dequeueReusableCell(ofType: AlbumCell.self, at: indexPath)
                .setup(with: viewModel)
        case .failed(.retryable(let message)):
            return collectionView.dequeueReusableCell(ofType: RetryCollectionViewCell.self, at: indexPath)
                .setup(with: message, onTap: { [output] in
                    output?.handle(action: .retry)
                })
        default:
            fatalError("no cell provided for this state")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            reload()
            activityView.animate()
        }
    }
}

extension AlbumsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return collectionView.frame.size
    }
}

// MARK: - AlbumsListViewControllerInput

extension AlbumsListViewController: AlbumsListViewControllerInput {
    func handle(state newState: ViewState<MediaMonksAlbumViewModel>) {
        self.state = .failed(.retryable("aaaa"))
        DispatchQueue.main.async {
            switch newState {
            case .idle:
                break
            case .loading(.initial):
                self.updateForLoadingState()
            case .loading(.new):
                self.updateForLoadingNewState()
            case .failed(.retryable(let message)),
                 .failed(.message(let message)):
                self.updateForErrorState(with: message)
            case .loaded:
                self.updateForLoadedState()
            }
        }
    }

    private func updateForLoadedState() {
        endRefreshing()
        collectionView.reloadData()
    }
}

// MARK: - Loading State

extension AlbumsListViewController {
    private func updateForLoadingNewState() {
        activityView.animate()
    }

    private func updateForLoadingState() {
        collectionView.reloadData()
        activityView.animate()
    }

    private func endRefreshing() {
        DispatchQueue.main.async {
            self.activityView.stopAnimating()
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - Error State

extension AlbumsListViewController {
    private func updateForErrorState(with message: String?) {
        endRefreshing()

        if let message = message {
            showError(with: message)
        } else {
            collectionView.reloadData()
        }
    }

    private func showError(with message: String) {
        // TODO: Anton - Show notification
    }
}

fileprivate extension ViewState where T == MediaMonksAlbumViewModel {
    var cellsCount: Int {
        switch self {
        case .idle: return 0
        case .loading(.initial): return 0
        case .loading(.new): return 0
        case .failed(.retryable): return 1 // provide a cell for retry state.
        case .failed(.message): return 0
        case .loaded(let items): return items.count // provide a cell for every album.
        }

    }

    var items: [MediaMonksAlbumViewModel] {
        switch self {
        case .loaded(let items): return items
        default: return []
        }
    }
}
