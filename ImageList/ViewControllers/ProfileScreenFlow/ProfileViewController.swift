import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
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
    
    let gradientView = GradientView()
    
    // MARK: - Dependency
    private let profileInfo: Profile?
    private let profileImageService: ProfileImageServiceProtocol
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - Init (Dependency injection)
    init(
        profileInfo: Profile?,
        profileImageService: ProfileImageServiceProtocol
    ) {
        self.profileInfo = profileInfo
        self.profileImageService = profileImageService
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
        updateAvatarImage(url: profileImageService.avatarUrl)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setConstraints()
    }
    
    private func updateAvatarImage(url: String?) {
        guard let avatarURLString = url,
            let url = URL(string: avatarURLString)
        else {
            return
        }
        
        portraitImage.kf.indicatorType = .activity
        portraitImage.kf.setImage(
            with: url,
            placeholder: UIImage.person,
            options: [.transition(.fade(0.5))]) { [weak self] result in
                switch result {
                case .success:
                    self?.gradientView.animationLayers
                        .forEach {
                            $0.removeAllAnimations()
                            $0.removeFromSuperlayer()
                        }
                case .failure:
                    break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObserver()
    }
    
    private func addObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main) { [weak self] notification in
                    guard let self = self else { return }
                    
                    let url = notification.userInfo?[UserInfo.url.rawValue] as? String
                    self.updateAvatarImage(url: url)
            }
    }
    
    @objc private func exitButtonDidTapped() {
        cleanWebViewSavedData()
        cleanTokenFromKeyChain()
        goToSplashViewController()
    }
    
    private func cleanWebViewSavedData() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record]) {}
            }
        }
    }
    
    private func cleanTokenFromKeyChain() {
        OAuth2TokenStorage().token = nil
    }
    
    private func goToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Wrong Configuration")
        }
        let splashViewController = SplashViewController(
            oAuth2Service: OAuth2Service(),
            profileService: ProfileService(),
            profileImageService: ProfileImageService(),
            oAuth2TokenStorage: OAuth2TokenStorage()
        )
        window.rootViewController = splashViewController
    }
}

// MARK: - UI
extension ProfileViewController {
    private func setView() {
        view.backgroundColor = .myBlack
        
        exitButton.addTarget(self, action: #selector(exitButtonDidTapped), for: .touchUpInside)
        
        [nameLabel, emailLabel, helloLabel]
            .forEach { verticalStackView.addArrangedSubview($0) }
        view.addSubviews(portraitImage, exitButton)
        view.addSubview(verticalStackView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.animationLayers.forEach { $0.animate(
            .locations,
            duration: 3,
            fromValue: [-1.0, -0.5, 0.0],
            toValue: [1.0, 1.5, 2.0],
            forKey: .locationsChanged)
        }
        view.addSubview(gradientView)
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
                constant: -24),
            
            gradientView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureUIWith(_ profile: Profile?) {
        guard let profile = profile else { return }
        nameLabel.text = profile.name.capitalized
        emailLabel.text = profile.loginName
        helloLabel.text = profile.bio
    }
}
