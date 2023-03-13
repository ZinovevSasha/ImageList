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
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    // MARK: - Dependency
    private let requests: UnsplashRequestProtocol
    
    // MARK: - Init (Dependency injection)
    init(requests: UnsplashRequestProtocol) {
        self.requests = requests
    }
    
    private(set) var avatarUrl: String?
       
    private func postNotification(about avatarUrl: String) {
        NotificationCenter.default
            .post(
                name: ProfileImageService.didChangeNotification,
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
        print("fetchProfileImageUrl true")
        let request = requests.userPortfolio(username: username)
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
