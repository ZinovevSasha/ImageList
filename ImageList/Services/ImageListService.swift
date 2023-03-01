//
//  ImageListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 18.02.2023.
//

import Foundation

protocol ImageListServiceProtocol {
    func fetchPhotosNextPage()
    func changeLike( photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    var photos: [Photos] { get }
}

final class ImageListService {
    static let DidChangeNotification = Notification.Name("ImageListService")
    private let session = URLSession.shared
    private var task: URLSessionTask?
    
    private var lastLoadedPage: Int?
    private(set) var photos: [Photos] = []
    
    private func postNotification(with numberOfPictures: Int) {
        NotificationCenter.default
            .post(
                name: ImageListService.DidChangeNotification,
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
        if task != nil {
            return
        }
        let request = UnsplashRequests.like(photoId: photoId, isLiked: isLiked).request
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
        if task != nil {
            return
        }
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        lastLoadedPage = nextPage

        let request = UnsplashRequests.photos(page: nextPage).request
        let task = session.object(
            for: request,
            expectedType: [PhotoResult].self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let photoResult):
                    let pictures = self.getPhotoArray(from: photoResult)
                    var numberOfPictures = 0
                    pictures.forEach { picture in
                        if !self.photos.contains(picture) {
                            self.photos.append(picture)
                            numberOfPictures += 1
                        }
                    }
                    self.postNotification(with: numberOfPictures)
                case .failure(let failure):
                    print(failure)
                }
                self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func getPhotoArray(from photoResult: [PhotoResult]) -> [Photos] {
        return photoResult.map {
            Photos(
                id: $0.id,
                size: CGSize(width: $0.width, height: $0.height),
                createdAt: $0.createdAt?.dateString ?? "",
                welcomeDescription: $0.description ?? "",
                thumbImageURL: $0.urls.thumb,
                largeImageURL: $0.urls.full,
                regular: $0.urls.regular,
                small: $0.urls.small,
                full: $0.urls.full,
                isLiked: $0.likedByUser
            )
        }
    }
    
    private struct LikeResult: Decodable {
        let photo: Photo
    }
    
    private struct Photo: Decodable {
        let likedByUser: Bool
    }
    
    private struct PhotoResult: Decodable {
        let id: String
        let createdAt: Date?
        let width, height: Double
        let likedByUser: Bool
        let description: String?
        let urls: UrlsResult
    }
    
    private struct UrlsResult: Decodable {
        let full: String
        let thumb: String
        let regular: String
        let small: String
    }
}
