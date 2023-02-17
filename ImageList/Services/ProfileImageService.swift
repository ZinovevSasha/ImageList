//
//  ProfileImageService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.02.2023.
//

import Foundation

protocol ProfileImageServiceProtocol {
    func fetchProfileImageUrl(
        username: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private let urlSession = URLSession.shared
    private(set) var avatarUrl: String?
       
    private func postNotification(of avatarUrl: String) {
        NotificationCenter.default
            .post(
                name: ProfileImageService.DidChangeNotification,
                object: self,
                userInfo: ["URL": avatarUrl]
            )
    }
}
 
extension ProfileImageService: ProfileImageServiceProtocol {
    func fetchProfileImageUrl(
        username: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = UnsplashRequests.userPortfolio(username: username).request
        let task = urlSession.object(
            for: request,
            expectedType: UserResult.self
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userResult):
                let avatarUrl = userResult.profileImage.large
                self.avatarUrl = avatarUrl
                self.postNotification(of: avatarUrl)
                completion(.success(avatarUrl))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
 
    private struct UserResult: Decodable {
        let profileImage: ProfileImage
        
        struct ProfileImage: Decodable {
            let small, medium, large: String
        }
    }
}
