import UIKit

final class ImagesListCell: UITableViewCell {
    static let identifier = String(describing: ImagesListCell.self)
    private let gradientLayer = CAGradientLayer()
    
    private let pictureImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let heartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(.noLike, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private let pictureImageContainer: UIView = {
        let container = UIView()
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    func setConstraint() {
        NSLayoutConstraint.activate([
            // dateContainer
            dateContainer.leadingAnchor.constraint(
                equalTo: pictureImageContainer.leadingAnchor),
            dateContainer.bottomAnchor.constraint(
                equalTo: pictureImageContainer.bottomAnchor),
            dateContainer.trailingAnchor.constraint(
                equalTo: pictureImageContainer.trailingAnchor),
            dateContainer.heightAnchor.constraint(equalToConstant: 30),
            
            // dateLabel
            dateLabel.leadingAnchor.constraint(
                equalTo: dateContainer.leadingAnchor,
                constant: 8),
            dateLabel.bottomAnchor.constraint(
                equalTo: dateContainer.bottomAnchor,
                constant: -8),
            dateLabel.trailingAnchor.constraint(
                equalTo: dateContainer.trailingAnchor,
                constant: -184),
            dateLabel.topAnchor.constraint(
                equalTo: dateContainer.topAnchor,
                constant: 4),
            
            // button
            heartButton.topAnchor.constraint(
                equalTo: pictureImageContainer.topAnchor),
            heartButton.trailingAnchor.constraint(
                equalTo: pictureImageContainer.trailingAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 42),
            heartButton.heightAnchor.constraint(equalToConstant: 42),
            
            // pictureImage
            pictureImage.leadingAnchor.constraint(
                equalTo: pictureImageContainer.leadingAnchor),
            pictureImage.topAnchor.constraint(
                equalTo: pictureImageContainer.topAnchor),
            pictureImage.trailingAnchor.constraint(
                equalTo: pictureImageContainer.trailingAnchor),
            pictureImage.bottomAnchor.constraint(
                equalTo: pictureImageContainer.bottomAnchor),
                        
            // pictureImageContainer
            pictureImageContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16),
            pictureImageContainer.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 4),
            pictureImageContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16),
            pictureImageContainer.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -4)
        ])
    }
    
    // MARK: - Configure function
    public func configure(model: ImageCell) {
        pictureImage.image = UIImage(named: model.image)
        dateLabel.text = model.date.dateString
        dateContainer.addGradient(
            with: gradientLayer,
            colorSet: [.myGradientStart, .myGradientStop],
            locations: [0.0, 1.0])
    }
    
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: self.layer)
    
        if gradientLayer.frame != dateContainer.bounds {
            gradientLayer.frame = dateContainer.bounds
        }
    }

    
    @objc private func heartButtonDidTapped() { }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
        
        heartButton.addTarget(
            self,
            action: #selector(heartButtonDidTapped),
            for: .touchUpInside)
        
        pictureImageContainer.addSubviews(pictureImage, heartButton, dateContainer)
        dateContainer.addSubview(dateLabel)
        contentView.addSubview(pictureImageContainer)
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImage.image = nil
        dateLabel.text = nil
    }
}

extension ImagesListCell {
    // Set Gradient
    private func setGradient() {
        gradientLayer.frame = dateContainer.bounds.insetBy(
            dx: -0.5 * dateContainer.bounds.size.width,
            dy: -0.5 * dateContainer.bounds.size.height
        )
        dateContainer.addGradient(
            with: gradientLayer,
            colorSet: [.myGradientStart, .myGradientStop],
            locations: [0.0, 1.0])
    }
}
