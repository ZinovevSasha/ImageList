//
//  Scopes.swift
//  ImageList
//
//  Created by Александр Зиновьев on 06.03.2023.
//

import Foundation

enum Scope {
    case `public`
    case readUser
    case writeLikes
    case readCollections
    case writeCollections
    
    var string: String {
        switch self {
        case .public:
            return "public"
        case .readUser:
            return "read_user"
        case .writeLikes:
            return "write_likes"
        case .readCollections:
            return "read_collections"
        case .writeCollections:
            return "write_collections"
        }
    }
}
