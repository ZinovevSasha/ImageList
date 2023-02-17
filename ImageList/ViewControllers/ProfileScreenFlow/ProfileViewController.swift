import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let portraitImage: UIImageView = {
        let image = UIImageView()
        image.cornerRadius = 35
        image.translatesAutoresizingMaskIntoConstraints = false
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
    
    // MARK: - Dependency
    private let profileInfo: Profile?
    private var profileImageServerObserver: NSObjectProtocol?

    // MARK: - Init (Dependency injection)
    init(profileInfo: Profile?) {
        self.profileInfo = profileInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        configureUIWith(profileInfo)
        updateAvatarImage(url: ProfileImageService.shared.avatarUrl)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setConstraints()
    }
    
    private func updateAvatarImage(url: String?) {
        guard let avatar = url,
            let url = URL(string: avatar)
        else {
            return
        }
        
        portraitImage.kf.indicatorType = .activity
        portraitImage.kf.setImage(
            with: url,
            placeholder: UIImage.person,
            options: [.transition(.fade(0.5))]
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObserver()
    }
    
    private func addObserver() {
        profileImageServerObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main) { [weak self] notification in
                    guard let self = self else { return }
                    
                    let url = notification.userInfo?["URL"] as? String
                    self.updateAvatarImage(url: url)
            }
    }
    
    @objc private func exitButtonDidTapped() { }
}

// MARK: - UI
extension ProfileViewController {
    private func setView() {
        view.backgroundColor = .myBlack
        
        exitButton.addTarget(self, action: #selector(exitButtonDidTapped), for: .touchDragInside)
        
        [nameLabel, emailLabel, helloLabel]
            .forEach { verticalStackView.addArrangedSubview($0) }
        view.addSubviews(portraitImage, exitButton)
        view.addSubview(verticalStackView)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // portraitImage
            portraitImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            portraitImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            portraitImage.heightAnchor.constraint(equalToConstant: 70),
            portraitImage.widthAnchor.constraint(equalToConstant: 70),
            
            // exitButton
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            
            // verticalStackView
            verticalStackView.topAnchor.constraint(
                equalTo: portraitImage.bottomAnchor, constant: 8),
            verticalStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            verticalStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24)
        ])
    }
    
    private func configureUIWith(_ profile: Profile?) {
        guard let profile = profile else { return }
        nameLabel.text = profile.name.capitalized
        emailLabel.text = profile.loginName
        helloLabel.text = profile.bio
    }
}
