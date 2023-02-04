//
//  OAuth2ServiceProtocol.swift
//  ImageList
//
//  Created by Александр Зиновьев on 02.02.2023.
//

protocol OAuth2ServiceProtocol {
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
}

