//
//  CustomGradientLayer.swift
//  ImageList
//
//  Created by Александр Зиновьев on 11.03.2023.
//

import UIKit

class CustomGradientLayer: CAGradientLayer {
    init(
        colors: [UIColor] = [.myShimmerColor, .white, .myShimmerColor],
        locations: [Double] = [0, 0.5, 1],
        startEndPoints: (CGPoint, CGPoint)? = (CGPoint.zero, CGPoint(x: 1, y: 0))
    ) {
        super.init()
        self.colors = colors.map { $0.cgColor }
        self.locations = locations.map { $0 as NSNumber }
        if let startEndPoints = startEndPoints {
            self.startPoint = startEndPoints.0
            self.endPoint = startEndPoints.1
        }
    }

    func animate(
        _ property: Animatable = .locations,
        duration: CFTimeInterval = 1.5,
        fromValue: Any? = [-1.0, -0.5, 0.0],
        toValue: Any? = [1.0, 1.5, 2.0],
        forKey: Keys = .locationsChanged
    ) {
        let animation = CABasicAnimation(keyPath: property.rawValue)
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.isRemovedOnCompletion = false
        self.add(animation, forKey: forKey.rawValue)
    }
    
    enum Animatable: String {
        case locations
    }
    
    enum Keys: String {
        case locationsChanged
    }
    
    
    required override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
