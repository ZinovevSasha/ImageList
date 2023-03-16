//
//  DetailImageListPresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.03.2023.
//

import Foundation
import Kingfisher
import UIKit

protocol DetailImageListPresenterProtocol {
    var view: DetailImageListViewControllerProtocol? { get } 
    func fetchImage(with url: URL)
}

final class DetailImageListPresenter {
    weak var view: DetailImageListViewControllerProtocol?
    
    init(view: DetailImageListViewControllerProtocol?) {
        self.view = view
    }
    
    // ImageState
    private enum DetailImageState {
        case loading
        case error(URL)
        case finished(UIImage)
    }
    
    private var imageState: DetailImageState = .loading {
        didSet {
            configureImageState()
        }
    }
    
    private func configureImageState() {
        switch imageState {
        case .loading:
            view?.startSpinner()
        case .error(let url):
            view?.stopSpinner()
            view?.showAlertAndMaybeTryAgainWith(url: url)
        case .finished(let image):
            view?.hideScribble()
            view?.stopSpinner()
            view?.didReceiveImage(image)
        }
    }
}

extension DetailImageListPresenter: DetailImageListPresenterProtocol {
    func fetchImage(with url: URL) {
        imageState = .loading
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                self.imageState = .finished(result.image)
            case .failure:
                self.imageState = .error(url)
            }
        }
    }
}
