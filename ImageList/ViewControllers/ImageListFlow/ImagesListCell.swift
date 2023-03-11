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
        button.adjustsImageWhenDisabled = false
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
        
    private var footerGradient = CustomGradientLayer(
        colors: [.myGradientStart, .myGradientStop],
        locations: [0, 1],
        startEndPoints: (CGPoint.zero, CGPoint(x: 0, y: 1))
    )

    private var placeholderGradient = CustomGradientLayer(
        colors: [.backgroundColorForShimmer, .shimmerColor, .backgroundColorForShimmer],
        locations: [0, 0.5, 1],
        startEndPoints: (CGPoint.zero, CGPoint(x: 1, y: 0))
    )

    // MARK: Public
    public func configure(with photoInfo: Photo) {
        imageState = .loading
        photoImageView.kf.setImage(with: URL(string: photoInfo.small)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                let cellViewModel = self.createCellViewModel(
                    image: result.image, photoInfo, gradient: self.footerGradient
                )
                self.imageState = .finished(cellViewModel)
            case .failure:
                self.imageState = .error
            }
        }
    }
    
    public func setLike(_ isLiked: Bool) {
        if isLiked {
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.likeButton.alpha = 0.3
                UIView.animate(withDuration: 0.5, delay: 0) {
                    self.likeButton.setImage(UIImage.like, for: .normal)
                    self.likeButton.alpha = 1
                    self.likeButton.transform = CGAffineTransform(scaleX: 2, y: 2)
                } completion: { done in
                    if done {
                        UIView.animate(withDuration: 0.5, delay: 0) {
                            self.likeButton.transform = .identity
                        }
                    }
                }
            }
        } else {
            self.likeButton.setImage(UIImage.noLike, for: .normal)
        }
    }

    // MARK: Dependency
    weak var delegate: ImageListTableViewCellDelegate?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setColors()        
        setTargets()
        addGradient()
        animateGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setConstraint()
        
        if footerGradient.frame != gradientContainerView.bounds {
            footerGradient.frame = gradientContainerView.bounds
        }
        if placeholderGradient.frame != photoContainer.bounds {
            placeholderGradient.frame = photoContainer.bounds
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.kf.cancelDownloadTask()
        configurePropertiesOrNil(nil)
        removeAnimation()
    }
    
    @objc private func likeButtonDidTapped() {
        delegate?.imageListCellDidTapLikeButton(self)
    }
    
    private func addGradient() {
        photoContainer.layer.insertSublayer(placeholderGradient, at: 1)
    }
    
    private func animateGradient() {
        placeholderGradient.animate()
    }
    
    private func removeAnimation() {
        placeholderGradient.removeAllAnimations()
        placeholderGradient.removeFromSuperlayer()
    }
    
    
    private enum CellImageState {
        case loading
        case error
        case finished(CellViewModel)
    }
    
    private var imageState: CellImageState = .loading {
        didSet {
            configureImageState()
        }
    }
    
    private func configureImageState() {
        switch imageState {
        case .loading:
            addGradient()
            animateGradient()
        case .error:
            removeAnimation()
        case .finished(let model):
            removeAnimation()
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
            footerGradient.removeFromSuperlayer()
        }
    }
    
    func createCellViewModel(image: UIImage, _ photo: Photo, gradient: CAGradientLayer) -> CellViewModel {
        let like = photo.isLiked ? UIImage.like : .noLike
        let date = photo.createdAt
        return CellViewModel(image: image, like: like, date: date, gradient: gradient)
    }
}

// MARK: - UI
private extension ImageListTableViewCell {
    func setColors() {
        contentView.backgroundColor = .myBlack
        contentView.addSubviews(photoContainer)
        photoContainer.backgroundColor = .white
        photoContainer
            .addSubviews(photoImageView, likeButton, gradientContainerView, dateLabel)
    }
    
    func setTargets() {
        likeButton.addTarget(self, action: #selector(likeButtonDidTapped), for: .touchDown)
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
