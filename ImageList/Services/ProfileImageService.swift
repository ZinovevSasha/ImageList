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
    var avatarUrl: String? { get }
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private(set) var avatarUrl: String?
       
    private func postNotification(about avatarUrl: String) {
        NotificationCenter.default
            .post(
                name: ProfileImageService.DidChangeNotification,
                object: self,
                userInfo: [UserInfo.url.rawValue: avatarUrl]
            )
    }
}
 
extension ProfileImageService: ProfileImageServiceProtocol {
    func fetchProfileImageUrl(
        username: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = UnsplashRequests.userPortfolio(username: username).request
        let task = URLSession.shared.object(
            for: request,
            expectedType: UserResult.self
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userResult):
                let avatarUrl = userResult.profileImage.large
                self.avatarUrl = avatarUrl
                self.postNotification(about: avatarUrl)
                completion(.success(avatarUrl))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
 
    private struct UserResult: Decodable {
        let profileImage: ProfileImage
    }
    
    private struct ProfileImage: Decodable {
        let small, medium, large: String
    }
}
