import UIKit
import Kingfisher

protocol ImageListTableViewCellDelegate: AnyObject {
    func imageListCellDidTapLikeButton(_ cell: ImageListTableViewCell)
}

final class ImageListTableViewCell: UITableViewCell {
    static let reusableIdentifier = String(describing: ImageListTableViewCell.self)

    var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private let photoImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
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
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private var gradientForBottomOfPicture: CAGradientLayer = {
        let layer = CAGradientLayer()
        let startColor = UIColor.myGradientStart
        let finishColor = UIColor.myGradientStop
        layer.colors = [startColor.cgColor, finishColor.cgColor]
        layer.startPoint = CGPoint.zero
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.masksToBounds = true
        return layer
    }()
    
    private var gradientLayer = CAGradientLayer()

    // MARK: Public
    public func configure(with photoInfo: Photos) {
        imageState = .loading
        photoImageView.kf.setImage(with: URL(string: photoInfo.small)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                let cellViewModel = self.createCellViewModel(
                    image: result.image, photoInfo, gradient: self.gradientForBottomOfPicture
                )
                self.imageState = .finished(cellViewModel)
            case .failure:
                self.imageState = .error
            }
        }
    }
    
    // MARK: Dependency
    weak var delegate: ImageListTableViewCellDelegate?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setColors()
        setSubviews()
        setConstraint()
        addGradientAndAnimate(true)
        likeButton.addTarget(
            self, action: #selector(likeButtonDidTapped), for: .touchDown)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradientForBottomOfPicture.frame != gradientContainerView.bounds {
            gradientForBottomOfPicture.frame = gradientContainerView.bounds
        }
        if gradientLayer.frame != photoContainer.bounds {
            gradientLayer.frame = photoContainer.bounds
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.kf.cancelDownloadTask()
        configurePropertiesOrNil(nil)
        addGradientAndAnimate(false)
    }
    
    @objc private func likeButtonDidTapped() {
        delegate?.imageListCellDidTapLikeButton(self)
    }
    
    public func setLike(_ isLiked: Bool) {
        let likeNoLike = isLiked ? UIImage.like : .noLike
        likeButton.setImage(likeNoLike, for: .normal)
    }
    
    enum FeedCellImageState {
        case loading
        case error
        case finished(CellViewModel)
    }
    
    var imageState: FeedCellImageState = .loading {
        didSet {
            configureImageState()
        }
    }
    
    private func configureImageState() {
        switch imageState {
        case .loading:
            addGradientAndAnimate(true)
        case .error:
            break
        case .finished(let model):
            addGradientAndAnimate(false)
            configurePropertiesOrNil(model)
        }
    }
        
    func configurePropertiesOrNil(_ model: CellViewModel?) {
        photoImageView.image = model?.image
        dateLabel.text = model?.date
        likeButton.setImage(model?.like, for: .normal)
        if let gradient = model?.gradient {
            gradientContainerView.layer.addSublayer(gradient)
        } else {
            gradientForBottomOfPicture.removeFromSuperlayer()
        }
    }
    
    func createCellViewModel(image: UIImage, _ photo: Photos, gradient: CAGradientLayer) -> CellViewModel {
        let like = photo.isLiked ? UIImage.like : .noLike
        let date = photo.createdAt
        return CellViewModel(image: image, like: like, date: date, gradient: gradient)
    }
}

// MARK: - UI
private extension ImageListTableViewCell {
    private func setColors() {
        contentView.backgroundColor = .myBlack
        photoContainer.backgroundColor = .myGray
    }
    
    private func setSubviews() {
        photoContainer.addSubviews(
            photoImageView,
            likeButton,
            gradientContainerView,
            dateLabel
        )
        contentView.addSubviews(photoContainer)
    }
    
    private func setConstraint() {
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
    
    private func addGradientAndAnimate(_ animate: Bool) {
        if animate {
            photoContainer.addGradient(
                with: gradientLayer,
                colorSet: [ .gray1, .gray2, .gray3],
                locations: [0, 0.5, 1],
                startEndPoints: (
                    CGPoint(x: 0, y: 0.5),
                    CGPoint(x: 1, y: 0.5)),
                insertAt: 1
            )
            gradientLayer.animate(
                .locations,
                duration: 3,
                fromValue: [-1.0, -0.5, 0.0],
                toValue: [1.0, 1.5, 2.0],
                forKey: .locationsChanged
            )
        } else {
            gradientLayer.removeAllAnimations()
            gradientLayer.removeFromSuperlayer()
        }
    }
}
