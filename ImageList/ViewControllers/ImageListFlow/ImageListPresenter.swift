//
//  ImageListPresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.03.2023.
//

import Foundation
import UIKit

protocol ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol? { get }
    func viewDidLoad()
    func heightForCell(at index: Int, widthOfScreen: CGFloat) -> CGFloat
    func getImageURL(at index: Int) -> String
    func getTotalNumberOfImages() -> Int
    func getPhoto(at index: Int) -> Photo
    func fetchNextPhotosIfNeeded(index: Int)
    func setLikeForPhotoAtIndex(index: Int, for cell: ImageListTableViewCell)
}

final class ImageListPresenter {
    private var imageListServiceObserver: NSObjectProtocol?
    
    // Dependency
    weak var view: ImageListViewControllerProtocol?
    private var imageListService: ImageListServiceProtocol
    
    init(
        view: ImageListViewControllerProtocol?,
        imageListService: ImageListServiceProtocol
    ) {
        self.view = view
        self.imageListService = imageListService
        
        subscribeToNotification()
        imageListService.fetchPhotosNextPage()    
    }
    
    private func subscribeToNotification() {
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .current) { [weak self] notification in
                guard let self = self,
                    let numberOfPictures = notification
                    .userInfo?[UserInfo.numberOfPictures.rawValue] as? Int
                else {
                    return
                }
            self.view?.stopSpinner()
            let indexPath = self.getIndexPath(from: numberOfPictures)
            self.view?.updateTableViewAnimated(at: indexPath)
        }
    }
    
    private func getIndexPath(from numberOfPictures: Int) -> [IndexPath] {
        let oldCount = imageListService.photos.count - numberOfPictures
        let newCount = imageListService.photos.count
        let indexPath = (oldCount..<newCount).map { IndexPath(row: $0, section: .zero) }
        return indexPath
    }
    
    private func getImageSize(at index: Int) -> CGSize {
        imageListService.photos[index].size
    }
}

extension ImageListPresenter: ImageListPresenterProtocol  {
    func viewDidLoad() {
        view?.startSpinner()
    }
    
    func setLikeForPhotoAtIndex(index: Int, for cell: ImageListTableViewCell) {
        let photo = getPhoto(at: index)
        
        view?.showProgress()
        imageListService.changeLike(
            photoId: photo.id,
            isLiked: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            self.view?.hideProgress()
            switch result {
            case .success:
                let like = self.imageListService.photos[index].isLiked
                self.view?.cellToggle(like: like, for: cell)
            case .failure:
                self.view?.showAlert()
            }
        }
    }
    
    func fetchNextPhotosIfNeeded(index: Int) {
        if index + 2 == getTotalNumberOfImages() {
            imageListService.fetchPhotosNextPage()
        }
    }
    
    func getPhoto(at index: Int) -> Photo {
        imageListService.photos[index]
    }
    
    func getTotalNumberOfImages() -> Int {
        imageListService.photos.count
    }
    
    func getImageURL(at index: Int) -> String {
        imageListService.photos[index].full
    }
    
    func heightForCell(at index: Int, widthOfScreen: CGFloat) -> CGFloat {
        let imageSize = getImageSize(at: index)
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = widthOfScreen - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        let scale = imageViewWidth / imageWidth
        let cellHeight = (imageHeight * scale) + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
