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
    static let shared = ProfileImageService(apiService: APIService())
    static let DidChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private(set) var avatarUrl: String?
    private let apiService: APIServiceProtocol
    
    private init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    private func subscribeToNotificationCenter(property: String) {
        NotificationCenter.default
            .post(
                name: ProfileImageService.DidChangeNotification,
                object: self,
                userInfo: ["URL": property]
            )
    }
    
    deinit {
        print("deinit... \(String(describing: self))")
    }
}
 
extension ProfileImageService: ProfileImageServiceProtocol {
    func fetchProfileImageUrl(
        username: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        apiService.fetch(
            request: .userPortfolio(username: username),
            expectedType: UserResult.self
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                let avatarUrl = success.profileImage.large
                self.avatarUrl = avatarUrl
                self.subscribeToNotificationCenter(property: avatarUrl)
                completion(.success(avatarUrl))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
 
    private struct UserResult: Decodable {
        let profileImage: ProfileImage
        
        struct ProfileImage: Decodable {
            let small, medium, large: String
        }
    }
}
