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
    func fetchProfile(
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        let request = UnsplashRequests.getMe.request
        let task = URLSession.shared.object(
            for: request,
            expectedType: ProfileResult.self
        ) { result in
            switch result {
            case .success(let profile):
                completion(.success(Profile(
                    username: profile.username,
                    name: profile.firstName + " " + profile.lastName,
                    loginName: "@" + profile.username,
                    bio: profile.bio ?? ""
                )))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private struct ProfileResult: Decodable {
        let username: String
        let firstName: String
        let lastName: String
        let bio: String?
    }
}
