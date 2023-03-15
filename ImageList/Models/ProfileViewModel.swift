//
//  ProfileViewModel.swift
//  ImageList
//
//  Created by Александр Зиновьев on 13.03.2023.
//

import Foundation

struct ProfileViewModel: Equatable {
    let portraitImageData: Data
    let name: String
    let email: String
    let greeting: String
    
    init(portraitImageData: Data, name: String, email: String, greeting: String) {
        self.portraitImageData = portraitImageData
        self.name = name
        self.email = email
        self.greeting = greeting
    }
}
