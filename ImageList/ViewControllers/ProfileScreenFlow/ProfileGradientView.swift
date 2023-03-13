import UIKit

final class ProfileGradientView: UIView {
    private let portraitImage = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let helloLabel = UILabel()
    
    private var portraitLayer = CustomGradientLayer()
    private let nameLayer = CustomGradientLayer()
    private let emailLayer = CustomGradientLayer()
    private let helloLayer = CustomGradientLayer()
    private var animationLayers = Set<CustomGradientLayer>()
    
    // MARK: - Public
    func animate() {
        animationLayers.forEach { $0.animate() }
    }
    
    func removeAllAnimations() {
        animationLayers.forEach { $0.removeAllAnimations() }
    }
    
    func removeFromSuperLayer() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setViews()
        addGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setConstraints()
        setFrames()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: - UI
private extension ProfileGradientView {
    func setViews() {
        addSubviews(portraitImage, nameLabel, emailLabel, helloLabel)
        [portraitImage, nameLabel, emailLabel, helloLabel]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        portraitImage.cornerRadius = 35
        nameLabel.cornerRadius = 9
        emailLabel.cornerRadius = 9
        helloLabel.cornerRadius = 9
    }
    
    func setFrames() {
        portraitLayer.frame = portraitImage.bounds
        nameLayer.frame = nameLabel.bounds
        emailLayer.frame = emailLabel.bounds
        helloLayer.frame = helloLabel.bounds
    }
    
    func addGradient() {
        let layers = [portraitLayer, nameLayer, emailLayer, helloLayer]
        [portraitImage, nameLabel, emailLabel, helloLabel]
            .enumerated()
            .forEach { $0.1.layer.insertSublayer(layers[$0.0], at: 1) }
        layers.forEach { animationLayers.insert($0) }
    }
    
    func setConstraints() {
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
}
