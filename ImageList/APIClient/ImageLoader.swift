//
//  ImageLoader.swift
//  ImageList
//
//  Created by Александр Зиновьев on 14.03.2023.
//

import Foundation

protocol ImageLoaderProtocol {
    func downloadImage(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

final class ImageLoader: ImageLoaderProtocol {
    private var imageDataCash = NSCache<NSString, NSData>()
    func downloadImage(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let key = url.absoluteString as NSString
        if let data = imageDataCash.object(forKey: key) {
            fulfillCompletion(.success(data as Data))
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                fulfillCompletion(.failure(URLError(.badServerResponse)))
                return
            }
            
            let value = data as NSData
            self?.imageDataCash.setObject(value, forKey: key)
            fulfillCompletion(.success(data))
        }
        task.resume()
    }
}
