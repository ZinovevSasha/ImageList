//
//  ImageListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 18.02.2023.
//

import Foundation

protocol ImageListServiceProtocol {
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    var photos: [Photo] { get }
}

final class ImageListService {
    static let didChangeNotification = Notification.Name("ImageListService")
    // MARK: - Dependency
    private let requests: UnsplashRequestProtocol
    
    // MARK: - Init (Dependency injection)
    init(requests: UnsplashRequestProtocol) {
        self.requests = requests
    }
    
    private var task: URLSessionTask?
    private let session = URLSession.shared
    
    private var lastLoadedPage: Int?
    private(set) var photos: [Photo] = []
    
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
}

extension ImageListService: ImageListServiceProtocol {
    func changeLike(
        photoId: String,
        isLiked: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard task == nil else { return }
        
        let request = requests.like(photoId: photoId, isLiked: isLiked)
        let task = session.object(
            for: request,
            expectedType: LikeResult.self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let isLiked):
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        self.photos[index].isLiked = isLiked.photo.likedByUser
                    }
                    completion(.success(Void()))
                case .failure(let failure):
                    print(failure)
                    completion(.failure(failure))
                }
                self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func fetchPhotosNextPage() {
        guard task == nil else { return }
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        lastLoadedPage = nextPage

        let request = requests.photos(page: nextPage)
        let task = session.object(
            for: request,
            expectedType: [PhotoResult].self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let photoResult):
                    let receivedPhotos = photoResult.map { $0.convertToPhotoModel() }
                    let newPhotos = receivedPhotos.filter { !self.photos.contains($0) }
                    self.photos.append(contentsOf: newPhotos)
                    self.postNotification(with: newPhotos.count)
                case .failure(let failure):
                    print(failure)
                }
                self.task = nil
        }
        self.task = task
        task.resume()
    }
}

fileprivate struct LikeResult: Decodable {
    let photo: Photos
}

fileprivate struct Photos: Decodable {
    let likedByUser: Bool
}

fileprivate struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date?
    let width, height: Double
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
}

fileprivate struct UrlsResult: Decodable {
    let full: String
    let thumb: String
    let regular: String
    let small: String
}

fileprivate extension PhotoResult {
    func convertToPhotoModel() -> Photo {
        Photo(
            id: self.id,
            size: CGSize(width: self.width, height: self.height),
            createdAt: self.createdAt?.dateString ?? "",
            welcomeDescription: self.description ?? "",
            thumbImageURL: self.urls.thumb,
            largeImageURL: self.urls.full,
            regular: self.urls.regular,
            small: self.urls.small,
            full: self.urls.full,
            isLiked: self.likedByUser
        )
    }
}
