//
//  GradientView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 27.02.2023.
//

import UIKit

class GradientView: UIView {
    private let portraitImage = UIImageView()
    private let portraitImageLayer = CAGradientLayer()
    private let nameLabel = UILabel()
    private let nameLabelLayer = CAGradientLayer()
    private let emailLabel = UILabel()
    private let emailLabelLayer = CAGradientLayer()
    private let helloLabel = UILabel()
    private let helloLabelLayer = CAGradientLayer()
    
    public var animationLayers = Set<CALayer>()
    
    func animate() {
        animationLayers.forEach { $0.animate(
            .locations,
            duration: 1.5,
            fromValue: [-1.0, -0.5, 0.0],
            toValue: [1.0, 1.5, 2.0],
            forKey: .locationsChanged)
        }
    }
    
    func stopAnimation() {
        animationLayers
            .forEach {
                $0.removeAllAnimations()
                $0.removeFromSuperlayer()
            }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupView()
        setupFrames()
        addConstraint()
        addGradient()
    }
    
    private func setupView() {
        [portraitImage, nameLabel, emailLabel, helloLabel]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        addSubviews(portraitImage, nameLabel, emailLabel, helloLabel)
        backgroundColor = .backgroundColorForShimmer
        portraitImage.cornerRadius = 35
        nameLabel.cornerRadius = 9
        emailLabel.cornerRadius = 9
        helloLabel.cornerRadius = 9
    }
    
    private func setupFrames() {
        portraitImageLayer.frame = portraitImage.bounds
        nameLabelLayer.frame = nameLabel.bounds
        emailLabelLayer.frame = emailLabel.bounds
        helloLabelLayer.frame = helloLabel.bounds
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            portraitImage.topAnchor.constraint(equalTo: topAnchor),
            portraitImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            portraitImage.heightAnchor.constraint(equalToConstant: 70),
            portraitImage.widthAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: portraitImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 18),
            nameLabel.widthAnchor.constraint(equalToConstant: 223),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            emailLabel.heightAnchor.constraint(equalToConstant: 18),
            emailLabel.widthAnchor.constraint(equalToConstant: 89),
            
            helloLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            helloLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            helloLabel.heightAnchor.constraint(equalToConstant: 18),
            helloLabel.widthAnchor.constraint(equalToConstant: 67)
        ])
    }
    
    private func addGradient() {
        let layers = [
            nameLabelLayer,
            emailLabelLayer,
            helloLabelLayer,
            portraitImageLayer
        ]
        
        [nameLabel, emailLabel, helloLabel, portraitImage]
            .enumerated()
            .forEach {
                $0.1.addGradient(
                    with: layers[$0.0],
                    colorSet: [ .shimmerColor, .backgroundColorForShimmer, .shimmerColor],
                    locations: [0, 0.5, 1],
                    startEndPoints: (
                        CGPoint(x: 0, y: 0.5),
                        CGPoint(x: 1, y: 0.5)),
                    insertAt: 0
                )
            }
        layers.forEach { animationLayers.insert($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}
