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
        case failed(String)
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
    }

    var output: AlbumsListViewControllerOutput?
    private var state: State = .idle {
        didSet {
            print(state)
        }
    }

    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        activityIndicator.center = view.center
    }
}

extension AlbumsListViewController {
    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true

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
            case .idle: break
            case .loading(.initial): self.updateForInitiallLoading()
            case .loading(.new): print("TODO - refresh toggled")
            case .failed(let error): print("TODO - error \(error)")
            case .loaded:
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
            }
        } 
    }

    private func updateForInitiallLoading() {
        collectionView.reloadData()
        activityIndicator.startAnimating()
    }
}


class A: UICollectionViewCell {

}
