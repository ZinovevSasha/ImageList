//
//  ConfettiAnimationEffect.swift
//  ImageList
//
//  Created by Александр Зиновьев on 09.02.2023.
//
import UIKit

final class ConfettiAnimationEffect {
    init(view: UIView, colors: [UIColor], position: CGPoint) {
        let layer = CAEmitterLayer()
        
        layer.emitterPosition = CGPoint(
            x: position.x,
            y: position.y
        )
        
        let cells: [CAEmitterCell] = colors.compactMap {
            let cell = CAEmitterCell()
            cell.scale = 0.02
            cell.emissionRange = .pi
            cell.lifetime = Float((view.frame.height * 0.29) / 10)
            cell.birthRate = 100
            cell.velocity = 29
            cell.color = $0.cgColor
            cell.contents = UIImage.whiteBox?.cgImage
            return cell
        }
        
        layer.emitterCells = cells
        view.layer.addSublayer(layer)
    }
}
