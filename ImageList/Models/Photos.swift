//
//  Photos.swift
//  ImageList
//
//  Created by Александр Зиновьев on 18.02.2023.
//
import Foundation

struct Photos: Hashable, Equatable {
    let id: String
    let size: CGSize
    let createdAt: String
    let welcomeDescription: String
    let thumbImageURL: String
    let largeImageURL: String
    let regular: String
    let small: String
    let full: String
    var isLiked: Bool
    
    static func == (lhs: Photos, rhs: Photos) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
