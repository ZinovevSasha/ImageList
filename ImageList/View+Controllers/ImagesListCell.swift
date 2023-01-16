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
                equalTo: pictureImageContainer.leadingAnchor,
                constant: 0),
            dateContainer.bottomAnchor.constraint(
                equalTo: pictureImageContainer.bottomAnchor,
                constant: 0),
            dateContainer.trailingAnchor.constraint(
                equalTo: pictureImageContainer.trailingAnchor,
                constant: 0),
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
                equalTo: pictureImageContainer.topAnchor,
                constant: 0),
            heartButton.trailingAnchor.constraint(
                equalTo: pictureImageContainer.trailingAnchor,
                constant: 0),
            heartButton.widthAnchor.constraint(equalToConstant: 42),
            heartButton.heightAnchor.constraint(equalToConstant: 42),
            
            // pictureImage
            pictureImage.leadingAnchor.constraint(
                equalTo: pictureImageContainer.leadingAnchor,
                constant: 0),
            pictureImage.topAnchor.constraint(
                equalTo: pictureImageContainer.topAnchor,
                constant: 0),
            pictureImage.trailingAnchor.constraint(
                equalTo: pictureImageContainer.trailingAnchor,
                constant: 0),
            pictureImage.bottomAnchor.constraint(
                equalTo: pictureImageContainer.bottomAnchor,
                constant: 0),
                        
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
        guard let image = UIImage(named: model.image) else {
            return
        }
        pictureImage.image = image
        dateLabel.text = model.date.dateString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        setGradient()
        setConstraint()
    }
    
    @objc private func heartButtonDidTapped() { }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        self.selectionStyle = .none
        
        heartButton.addTarget(
            self,
            action: #selector(heartButtonDidTapped),
            for: .touchUpInside)
        
        dateContainer.addSubview(dateLabel)
        pictureImageContainer.addSubviews(pictureImage, heartButton, dateContainer)
        contentView.addSubview(pictureImageContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureImage.image = nil
        dateLabel.text = nil
        heartButton.setImage(nil, for: .normal)
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
