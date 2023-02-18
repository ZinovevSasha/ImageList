//
//  Array+Extensions.swift
//  ImageList
//
//  Created by Александр Зиновьев on 14.02.2023.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
