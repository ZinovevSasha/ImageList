//
//  ImageListPresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.03.2023.
//

import Foundation

protocol ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol? { get }
    func viewDidLoad()
    func heightForCell(at index: Int, widthOfScreen: CGFloat) -> CGFloat
    func getImageURL(at index: Int) -> String
    func getTotalNumberOfImages() -> Int
    func getPhoto(at indexPath: IndexPath) -> Photo
    func fetchNextPhotosIfNeeded(index: Int)
    func setLikeForPhoto(at indexPath: IndexPath)
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
    }
    
    func fetchPhotosNextPage() {
        imageListService.fetchPhotosNextPage { [weak self] _ in
            guard let self = self else { return }
            self.view?.showAlert { _ in
                self.fetchPhotosNextPage()
            }
        }
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
            
            let indexPath = self.getIndexPath(from: numberOfPictures)
            self.view?.hideProgress()
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
        view?.showProgress()
        subscribeToNotification()
        fetchPhotosNextPage()
    }
    
    func setLikeForPhoto(at indexPath: IndexPath) {
        let photo = getPhoto(at: indexPath)
        
        view?.showProgress()
        imageListService.changeLike(
            photoId: photo.id,
            isLiked: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            self.view?.hideProgress()
            switch result {
            case .success:
                let like = self.getPhoto(at: indexPath).isLiked
                self.view?.toggle(like: like, at: indexPath)
            case .failure:
                self.view?.showAlert(nil)
            }
        }
    }
    
    func fetchNextPhotosIfNeeded(index: Int) {
        if index + 2 == getTotalNumberOfImages() {
            imageListService.fetchPhotosNextPage { [weak self] _ in
                self?.view?.showAlert(nil)
            }
        }
    }
    
    func getPhoto(at indexPath: IndexPath) -> Photo {
        imageListService.photos[indexPath.row]
    }
    
    func getTotalNumberOfImages() -> Int {
        imageListService.photos.count
    }
    
    func getImageURL(at index: Int) -> String {
        imageListService.photos[index].full
    }
    
    func heightForCell(at index: Int, widthOfScreen: CGFloat) -> CGFloat {
        let imageSize = getImageSize(at: index)
        let imageInsets = EdgeInsets(top: 4, left: 16, right: 16, bottom: 4)
        let imageViewWidth = widthOfScreen - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        let scale = imageViewWidth / imageWidth
        let cellHeight = (imageHeight * scale) + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
