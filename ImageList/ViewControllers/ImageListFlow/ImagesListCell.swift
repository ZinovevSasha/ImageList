import UIKit

final class ImageTableViewCell: UITableViewCell {
    static let reusableIdentifier = String(describing: ImageTableViewCell.self)

    private let photoImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let likeButton: UIButton = {
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
    
    private let gradientContainerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private let photoContainer: UIView = {
        let container = UIView()
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private var gradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        let startColor = UIColor.myGradientStart
        let finishColor = UIColor.myGradientStop
        layer.colors = [startColor.cgColor, finishColor.cgColor]
        
        layer.startPoint = CGPoint.zero
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.shouldRasterize = true
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        layer.masksToBounds = true
        return layer
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setViews()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    
    // MARK: - Configure function
    public func configureCell(with model: Photo) {
        dateLabel.text = model.createdAt
        let heart = model.isLiked ? UIImage.like : UIImage.noLike
        likeButton.setImage(heart, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradient.frame != gradientContainerView.bounds {
            gradient.frame = gradientContainerView.bounds
        }
    }
    
    @objc private func heartButtonDidTapped() { }
}

// MARK: - UI
extension ImageTableViewCell {
    private func setViews() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
        likeButton.addTarget(self, action: #selector(heartButtonDidTapped), for: .touchUpInside)
        gradientContainerView.layer.addSublayer(gradient)
        photoContainer.addSubviews(photoImageView, likeButton, gradientContainerView, dateLabel)
        contentView.addSubview(photoContainer)
    }
    
    func setConstraint() {
        NSLayoutConstraint.activate([
            // dateContainer
            gradientContainerView.leadingAnchor.constraint(equalTo: photoContainer.leadingAnchor),
            gradientContainerView.bottomAnchor.constraint(equalTo: photoContainer.bottomAnchor),
            gradientContainerView.trailingAnchor.constraint( equalTo: photoContainer.trailingAnchor),
            gradientContainerView.heightAnchor.constraint(equalToConstant: 30),
            
            // dateLabel
            dateLabel.leadingAnchor.constraint(
                equalTo: photoContainer.leadingAnchor,
                constant: 8),
            dateLabel.bottomAnchor.constraint(
                equalTo: photoContainer.bottomAnchor,
                constant: -8),
            
            // button
            likeButton.topAnchor.constraint( equalTo: photoContainer.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: photoContainer.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 42),
            likeButton.heightAnchor.constraint(equalToConstant: 42),
            
            // pictureImage
            photoImageView.leadingAnchor.constraint(equalTo: photoContainer.leadingAnchor),
            photoImageView.topAnchor.constraint( equalTo: photoContainer.topAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: photoContainer.trailingAnchor),
            photoImageView.bottomAnchor.constraint( equalTo: photoContainer.bottomAnchor),
            
            // pictureImageContainer
            photoContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16),
            photoContainer.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 4),
            photoContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16),
            photoContainer.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -4)
        ])
    }
}
