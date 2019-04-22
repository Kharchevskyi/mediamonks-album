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
    func handle(state: AlbumsListViewController.State)
}

protocol AlbumsListViewControllerOutput {
    func handle(action: AlbumsListInteractor.Action)
}

// MARK: - Implementation

final class AlbumsListViewController: UIViewController {
    enum State: Equatable {
        case idle
        case loading(Loading)
        case failed(ErrorState)
        case loaded([MediaMonksAlbumViewModel])

        enum Loading {
            case initial
            case new
        }

        var items: [MediaMonksAlbumViewModel] {
            switch self {
            case .loaded(let items): return items
            default: return []
            }
        }

        enum ErrorState: Equatable {
            case retryable(String)
            case message(String)
        }
    }

    var output: AlbumsListViewControllerOutput?
    private var state: State = .idle {
        didSet {
            print(state)
        }
    }

    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private let collectionViewLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )
    private lazy var activityView = CustomRefreshControlView(
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

}

extension AlbumsListViewController {
    private func setupUI() {
        view.backgroundColor = .black

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: A.self)
        collectionView.addSubview(refreshControl)
        view.addSubview(collectionView)
        view.constrainToEdges(collectionView)

        activityView.textColor = .white
        activityView.font = UIFont.boldSystemFont(ofSize: 16)

        refreshControl.addSubview(activityView)
        refreshControl.tintColor = .clear
        refreshControl.constrainToEdges(activityView, insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        refreshControl.beginRefreshing()
        activityView.animate()
    }

    private func endRefreshing() {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.activityView.stopAnimating()
        }
    }

    @objc private func reload() {
        output?.handle(action: .loadNew)
    }
}

extension AlbumsListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return state.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: A.self, at: indexPath)
        cell.backgroundColor = .red
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            activityView.animate()
        }
    }
}

extension AlbumsListViewController: AlbumsListViewControllerInput {
    func handle(state newState: AlbumsListViewController.State) {
        if newState != self.state { self.state = newState }
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

    private func updateForRetryState(with string: String) {

    }

    private func updateForErrorState(with string: String) {

    }

    private func updateForLoadingState() {
        collectionView.reloadData()
    }

    private func updateForLoadingNewState() {

    }

    private func updateForLoadedState() {
        endRefreshing()
        collectionView.reloadData()
    }

}


class A: UICollectionViewCell {

}
