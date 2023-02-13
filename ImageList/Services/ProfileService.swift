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

final class ProfileService {
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    deinit {
        print("deinit... \(String(describing: self))")
    }
}

extension ProfileService: ProfileServiceProtocol {
    func fetchProfile(
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        apiService.fetch(
            request: .getMe,
            expectedType: ProfileResult.self
        ) { result in
            switch result {
            case .success(let body):
                completion(.success(Profile(
                    username: body.username,
                    name: body.firstName + " " + body.lastName,
                    loginName: "@" + body.username,
                    bio: body.bio ?? "Hello, world!"
                )))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    private struct ProfileResult: Decodable {
        let username: String
        let firstName: String
        let lastName: String
        let bio: String?
    }
}
