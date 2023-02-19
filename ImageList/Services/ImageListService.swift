//
//  ImageListService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 18.02.2023.
//

import Foundation

protocol ImageListServiceProtocol {
    func fetchPhotosNextPage()
    var photos: [Photo] { get }
}

final class ImageListService {
    static let DidChangeNotification = Notification.Name("ImageListService")
    private let session = URLSession.shared
    private var task: URLSessionTask?
    
    init() {
        fetchPhotosNextPage()
    }
    
    private var lastLoadedPage: Int?
    private(set) var photos: [Photo] = []
    
    private func postNotification(about photos: [Photo]) {
        NotificationCenter.default
            .post(
                name: ImageListService.DidChangeNotification,
                object: self,
                userInfo: ["Photos": photos]
            )
    }
}

extension ImageListService: ImageListServiceProtocol {
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
                    let photos = self.getPhotos(from: photoResult)
                    self.photos.append(contentsOf: photos)
                    self.postNotification(about: photos)
                case .failure(let failure):
                    print(failure)
                }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func getPhotos(from photoResult: [PhotoResult]) -> [Photo] {
        return photoResult.map {
            Photo(
                id: $0.id,
                size: CGSize(width: $0.width, height: $0.height),
                createdAt: $0.createdAt.dateString,
                welcomeDescription: $0.description ?? "",
                thumbImageURL: $0.urls.thumb,
                largeImageURL: $0.urls.full,
                isLiked: $0.likedByUser
            )
        }
    }
    
    private struct PhotoResult: Decodable {
        let id: String
        let createdAt: Date
        let width, height: Double
        let likedByUser: Bool
        let description: String?
        let urls: UrlsResult
    }
    
    private struct UrlsResult: Decodable {
        let full: String
        let thumb: String
    }
}
