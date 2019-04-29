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
    enum LocalConstants {
        static let insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        static let minimumInteritemSpacing: CGFloat = 6
    }

    var output: AlbumsListViewControllerOutput?
    private var state: ViewState<MediaMonksAlbumViewModel> = .idle
    private let refreshControl = UIRefreshControl()
    private let collectionViewLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )
    private lazy var activityView = CustomRefreshControl(
        text: Constants.appName,
        refreshControl: refreshControl
    )

    private var navigationControllerDelegate: CustomNavigationControllerDelegate?

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
        navigationControllerDelegate = CustomNavigationControllerDelegate(navigationController: self.navigationController!)

        view.backgroundColor = Constants.Colors.mainColor

        collectionView.delegate = self
        collectionView.backgroundColor = Constants.Colors.mainColor
        collectionView.dataSource = self
        collectionView.register(cellType: AlbumCell.self)
        collectionView.register(cellType: RetryCollectionViewCell.self)
        collectionView.register(cellType: AlbumLoadingCollectionViewCell.self)
        view.addSubview(collectionView)
        view.constrainToEdges(collectionView)

        collectionView.addSubview(refreshControl)
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
            case .loading(.initial):
            return collectionView.dequeueReusableCell(ofType: AlbumLoadingCollectionViewCell.self, at: indexPath)
                .setup(with: "Loading", subtitle: "🤞🤞🤞🤞🤞", onTap: nil)
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case let .loaded(items) = state,
            let itemId = items[safe: indexPath.row]?.id
        else { return }

        output?.handle(action: .proceed(.photos(itemId)))
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
        switch state {
        case .failed(.retryable),
             .loading(.initial):
            return CGSize(
                width: collectionView.frame.size.width
                    - LocalConstants.insets.left
                    - LocalConstants.insets.right,
                height: collectionView.frame.size.height
                    - LocalConstants.insets.top
                    - LocalConstants.insets.bottom
            )
        case .loaded:
            let width = collectionView.frame.size.width / 3
                - LocalConstants.insets.left
                - LocalConstants.insets.right
            return CGSize(
                width: width,
                height: width
            )
        default:
            return .zero
        }
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return LocalConstants.insets
    }
}

// MARK: - AlbumsListViewControllerInput

extension AlbumsListViewController: AlbumsListViewControllerInput {
    func handle(state newState: ViewState<MediaMonksAlbumViewModel>) {
        self.state = newState
        DispatchQueue.main.async {
            switch newState {
            case .idle:
                break
            case .loading(.initial):
                self.updateForLoadingState()
            case .loading(.new):
                self.updateForLoadingNewState()
            case .failed(.retryable(let message)):
                self.updateForRetryState(with: message)
            case .failed(.message(let message)):
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
    private func updateForErrorState(with message: String) {
        endRefreshing()
        showError(with: message)
    }

    private func showError(with message: String) {
        // TODO: Anton - Show notification
    }

    private func updateForRetryState(with message: String) {
        endRefreshing()
        collectionView.reloadData()
    }
}
