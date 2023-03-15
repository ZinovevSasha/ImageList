//
//  ImageListPresenterTests.swift
//  ImageListTests
//
//  Created by Александр Зиновьев on 15.03.2023.
//

import XCTest
@testable import ImageList

final class ImageListPresenterTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let imageListPresenterSpy = ImageListPresenterSpy()
        let imageListViewController = ImagesListViewController()
        imageListViewController.presenter = imageListPresenterSpy
        imageListPresenterSpy.view = imageListViewController
        
        // When
        _ = imageListViewController.view
        
        // Then
        XCTAssertTrue(imageListPresenterSpy.viewDidLoadCalled)
    }
    
    func testPresenterCalculatesIndexPathCorrectlyAndCallsViewMethods() {
        // Given
        let imageListServiceMock = ImageListServiceMock(simulateError: false)
        let imageListPresenter = ImageListPresenter(
            view: nil,
            imageListService: imageListServiceMock
        )
        let view = ImageListViewControllerSpy(presenter: imageListPresenter)
        imageListPresenter.view = view
        
        // When
        view.presenter.viewDidLoad()
        
        // Than
        XCTAssertTrue(view.showProgressCalled)
        XCTAssertTrue(view.hideProgressCalled)
        XCTAssertEqual(view.indexes?.count, 2)
    }
    
    func testPresenterSetLikeForSelectedCell() {
        // Given
        let imageListServiceMock = ImageListServiceMock(simulateError: false)
        let imageListPresenter = ImageListPresenter(
            view: nil,
            imageListService: imageListServiceMock
        )
        let view = ImageListViewControllerSpy(presenter: imageListPresenter)
        imageListPresenter.view = view
        
        // When
        view.presenter.setLikeForPhoto(at: IndexPath(row: 2, section: 0))
        
        // Then
        XCTAssertTrue(view.showProgressCalled)
        XCTAssertTrue(view.isLiked)
        XCTAssertEqual(view.index, 2)
    }
    
    func testPresenterFailToSetLikeForSelectedCell() {
        // Given
        let imageListServiceMock = ImageListServiceMock(simulateError: true)
        let imageListPresenter = ImageListPresenter(
            view: nil,
            imageListService: imageListServiceMock
        )
        let view = ImageListViewControllerSpy(presenter: imageListPresenter)
        imageListPresenter.view = view
        // When
        view.presenter.setLikeForPhoto(at: IndexPath(row: 2, section: 0))
        // Then
        XCTAssertTrue(view.alertShown)
        
    }
}

final class ImageListPresenterSpy: ImageListPresenterProtocol {
    var view: ImageList.ImageListViewControllerProtocol?
    
    // viewDidLoadCalles
    var viewDidLoadCalled = false
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func heightForCell(at index: Int, widthOfScreen: CGFloat) -> CGFloat {
        return 0
    }
    
    func getImageURL(at index: Int) -> String {
        return ""
    }
    
    func getTotalNumberOfImages() -> Int {
        return 0
    }
    
    func getPhoto(at indexPath: IndexPath) -> ImageList.Photo {
        return Photo(
            id: "",
            size: CGSize(width: 0, height: 0),
            createdAt: "",
            welcomeDescription: "",
            thumbImageURL: "",
            largeImageURL: "",
            regular: "",
            small: "",
            full: "",
            isLiked: true
        )
    }
    
    func setLikeForPhoto(at indexPath: IndexPath) {
        
    }
    
    func fetchNextPhotosIfNeeded(index: Int) {
        
    }
}

final class ImageListViewControllerSpy: ImageListViewControllerProtocol {
    var presenter: ImageList.ImageListPresenterProtocol
    init(presenter: ImageList.ImageListPresenterProtocol) {
        self.presenter = presenter
    }
       
    // showProgress
    var showProgressCalled = false
    func showProgress() {
        showProgressCalled = true
    }
    
    // hideProgress
    var hideProgressCalled = false
    func hideProgress() {
        hideProgressCalled = true
    }
    
    // updateTableViewAnimated
    var indexes: [IndexPath]?
    func updateTableViewAnimated(at indexPath: [IndexPath]) {
        indexes = indexPath
    }
    
    // Like
    var isLiked = false
    var index: Int?
    func toggle(like: Bool, at indexPath: IndexPath) {
        isLiked = like
        index = indexPath.row
    }
    
    // showAlert
    var alertShown = false
    func showAlert(_ completion: ((UIAlertAction) -> Void)?) {
        alertShown = true
    }
}

final class ImageListServiceMock: ImageListServiceProtocol {
    static let didChangeNotification = Notification.Name("ImageListService")
    private func postNotification(with numberOfPictures: Int) {
        NotificationCenter.default
            .post(
                name: ImageListService.didChangeNotification,
                object: self,
                userInfo: [
                    UserInfo.photos.rawValue: photos,
                    UserInfo.numberOfPictures.rawValue: numberOfPictures
                ]
            )
    }
    
    init(simulateError: Bool) {
        self.simulateError = simulateError
    }
    
    func fetchPhotosNextPage(completion: @escaping (String) -> Void) {
        if simulateError {
            completion("error")
        } else {
            postNotification(with: 2)
        }
    }
    
    // changeLike
    var simulateError: Bool
    func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        if simulateError {
            completion(.failure(FakeError.failureToLoad))
        } else {
            completion(.success(Void()))
        }
    }
    
    var photos: [Photo] = Array(
        repeating: Photo(
            id: "",
            size: CGSize(width: 0, height: 0),
            createdAt: "",
            welcomeDescription: "",
            thumbImageURL: "",
            largeImageURL: "",
            regular: "",
            small: "",
            full: "",
            isLiked: true),
        count: 10
    )
}
