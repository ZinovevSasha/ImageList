//
//  ProfileService.swift
//  ImageList
//
//  Created by Александр Зиновьев on 07.02.2023.
//

import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile(
        completion: @escaping (Result<Profile, Error>) -> Void
    )
}

final class ProfileService: ProfileServiceProtocol {
    // MARK: - Dependency
    private let requests: UnsplashRequestProtocol
    
    // MARK: - Init (Dependency injection)
    init(requests: UnsplashRequestProtocol) {
        self.requests = requests
    }
    
    func fetchProfile(
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        print("True fetchProfile")
        let request = requests.getMe()
        let task = URLSession.shared.object(
            for: request,
            expectedType: ProfileResult.self
        ) { result in
            switch result {
            case .success(let profile):
                completion(.success( profile.convertToProfileModel() ))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

fileprivate struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
}

fileprivate extension ProfileResult {
    func convertToProfileModel() -> Profile {
        Profile(
            username: self.username,
            name: self.firstName + " " + self.lastName,
            loginName: "@" + self.username,
            bio: self.bio ?? ""
        )
    }
}
