//
//  CAGradientLayer.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2023.
//

import UIKit

extension CALayer {
    enum Animatable: String {
        case locations
    }
    
    enum Keys: String {
        case locationsChanged
    }
    
    func animate(_ property: Animatable, duration: CFTimeInterval, fromValue: Any?, toValue: Any?, forKey: Keys) {
        let animation = CABasicAnimation(keyPath: property.rawValue)
        animation.duration = duration   
        animation.repeatCount = .infinity
        animation.fromValue = fromValue
        animation.toValue = toValue
        self.add(animation, forKey: forKey.rawValue)
    }
}
