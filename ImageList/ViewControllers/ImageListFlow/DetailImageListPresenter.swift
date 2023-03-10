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
    func fetchImage(with url: URL)
    func configureImageInScrollview(
        _ imageSize: CGSize,
        _ scrollViewBoundsSize: CGSize,
        _ minScale: CGFloat,
        _ maxScale: CGFloat
    )
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
            view?.showAlert(url: url)
        case .finished(let data):
            view?.hideScribble()
            view?.stopSpinner()
            view?.didReceiveImageData(data)
        }
    }
    
    func rescaleImageInScrollView(
        _ imageSize: CGSize,
        _ scrollViewBoundsSize: CGSize,
        _ minScale: CGFloat,
        _ maxScale: CGFloat
    ) {
        let minZoomScale = minScale
        let maxZoomScale = maxScale
        let visibleRectSize = scrollViewBoundsSize
       
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let theoreticalScale = max(hScale, vScale)
        let scale = min(maxZoomScale, max(minZoomScale, theoreticalScale))
        view?.scrollViewSetScale(scale)
        
        guard
            let newContentsSize = view?.scrollViewLayoutIfNeeded()
        else {
            return
        }
        let x = (newContentsSize.width - visibleRectSize.width) / 2
        let y = (newContentsSize.height - visibleRectSize.height) / 2
        view?.scrollViewSetContentOffset(offset: CGPoint(x: x, y: y))
    }
}

extension DetailImageListPresenter: DetailImageListPresenterProtocol {
    func configureImageInScrollview(
        _ imageSize: CGSize,
        _ scrollViewBoundsSize: CGSize,
        _ minScale: CGFloat,
        _ maxScale: CGFloat
    ) {
        rescaleImageInScrollView(imageSize, scrollViewBoundsSize, minScale, maxScale)
    }
    
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
