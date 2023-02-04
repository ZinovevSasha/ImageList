import UIKit

final class ProfileViewController: UIViewController {
    private let portraitImage: UIImageView = {
        let image = UIImageView()
        image.image = .person
        image.translatesAutoresizingMaskIntoConstraints = false
        image.setContentHuggingPriority(UILayoutPriority(252), for: .horizontal)
        return image
    }()
    
    private let exitButton: UIButton = {
        let image = UIButton()
        image.setImage(.exit, for: .normal)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .white
        label.text = "Aleksandr Zinovev Aleksandrovich"
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "blip@gmail.com"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let helloLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Hello, world! This is my favorite pictures. Take a look"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.backgroundColor = .clear
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setConstraints()
    }
    
    private func setViews() {
        view.backgroundColor = .myBlack
        view.addSubview(verticalStackView)
        
        exitButton.addTarget(self, action: #selector(exitButtonDidTapped), for: .touchDragInside)
        
        [portraitImage, exitButton]
            .forEach { horizontalStackView.addArrangedSubview($0) }
        
        [horizontalStackView, nameLabel, emailLabel, helloLabel]
            .forEach { verticalStackView.addArrangedSubview($0) }
    }
    
    @objc private func exitButtonDidTapped() {
        exitButton.isHidden = true
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // verticalStackView
            verticalStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 32),
            verticalStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            verticalStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24),
            
            // horizontalStackView
            horizontalStackView.topAnchor.constraint(equalTo: verticalStackView.topAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor)
        ])
    }
}
