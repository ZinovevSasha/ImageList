//
//  SpiningCircleView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 15.02.2023.
//

import UIKit

class SpinningCircleView: UIView {
    let spinningCircleView = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        
        let rect = self.bounds
        let circularPath = UIBezierPath(ovalIn: rect)
        
        spinningCircleView.path = circularPath.cgPath
        spinningCircleView.fillColor = UIColor.clear.cgColor
        spinningCircleView.strokeColor = UIColor.white.cgColor
        spinningCircleView.lineWidth = 10
        spinningCircleView.strokeEnd = 0.2
        spinningCircleView.lineCap = .round
        
        self.layer.addSublayer(spinningCircleView)
    }
    
    func animate() {
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear) {
            self.transform = CGAffineTransform(rotationAngle: .pi)
        } completion: { _ in
            UIView.animate(withDuration: 1, delay: 0, options: .curveLinear) {
                self.transform = CGAffineTransform(rotationAngle: 0)
            } completion: { _ in
                self.animate()
            }
        }
    }
}
