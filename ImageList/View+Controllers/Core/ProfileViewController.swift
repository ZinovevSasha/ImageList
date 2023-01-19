import UIKit

final class ProfileViewController: UIViewController {
    let portraitImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.person
        image.translatesAutoresizingMaskIntoConstraints = false
        image.setContentHuggingPriority(UILayoutPriority(252), for: .horizontal)
        return image
    }()
    
    let exitButton: UIButton = {
        let image = UIButton()
        image.setImage(.exit, for: .normal)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.text = "Aleksandr Zinovev"
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "blip@gmail.com"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let helloLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Hello, world!"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = .spacingStack
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.backgroundColor = .clear
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setConstraints()
    }
    
    func setViews() {
        view.backgroundColor = .myBlack
        view.addSubview(verticalStackView)
        [portraitImage, exitButton].forEach { horizontalStackView.addArrangedSubview($0) }
        [horizontalStackView, nameLabel, emailLabel, helloLabel].forEach { verticalStackView.addArrangedSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            // verticalStackView
            verticalStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: .topProfileScreenSpacing),
            verticalStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: .leftSpacing),
            verticalStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -26),
            
            // horizontalStackView
            horizontalStackView.topAnchor.constraint(equalTo: verticalStackView.topAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor)
        ])
    }
}
