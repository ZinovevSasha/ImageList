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
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let helloLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
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
    private let profileImageService: ProfileImageServiceProtocol
    private let profileService: ProfileServiceProtocol
    private var profileImageServiceObserver: NSObjectProtocol?

    private var profileInfo: Profile?
    
    // MARK: - Init (Dependency injection)
    init(
        profileImageService: ProfileImageServiceProtocol,
        profileService: ProfileServiceProtocol
    ) {
        self.profileImageService = profileImageService
        self.profileService = profileService
        super.init(nibName: nil, bundle: nil)
        fetchProfile()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        updateAvatarImage(url: profileImageService.avatarUrl)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setConstraints()
    }
    
    enum ProfilePersonalDataState {
        case loading
        case error
        case finished(UIImage)
    }
    
    var profileState: ProfilePersonalDataState = .loading {
        didSet {
            configureImageState()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if nameLabel.text == nil {
            
        }
    }
    
    private func configureImageState() {
        switch profileState {
        case .loading:
            view.addSubview(gradientView)
            gradientView.isHidden = false
        case .error:
            break
        case .finished(let image):
            gradientView.animationLayers
                .forEach {
                    $0.removeAllAnimations()
                    $0.removeFromSuperlayer()
                }
            gradientView.isHidden = true
            configureUI(with: image)
        }
    }
    
    private func configureUI(with image: UIImage) {
        portraitImage.image = image
        nameLabel.text = profileInfo?.name
        emailLabel.text = profileInfo?.loginName
        helloLabel.text = profileInfo?.bio
    }
    
    private func updateAvatarImage(url: String?) {
        profileState = .loading
        guard let avatarURLString = url,
            let url = URL(string: avatarURLString)
        else {
            return
        }
        portraitImage.kf.setImage(with: url) { [weak self] result in
            switch result {
            case .success(let result):
                self?.profileState = .finished(result.image)
            case .failure:
                self?.profileState = .error
            }
        }
    }
    
    private func fetchProfile() {
        profileService.fetchProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profileInfo = profile
                self.fetchProfileImageUrl(username: profile.username)
            case .failure:
                self.profileState = .error
            }
        }
    }
    
    private func fetchProfileImageUrl(username: String) {
        profileImageService
            .fetchProfileImageUrl(username: username) { [weak self] result in
                guard case .failure = result else { return }
                self?.profileState = .error
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
        openAlert(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            alertStyle: .alert,
            actionTitles: ["Нет", "Да"],
            actionStyles: [.cancel, .default],
            actions: [
                { _ in },
                { [weak self] _ in
                    guard let self = self else { return}
                    self.cleanWebViewSavedData()
                    self.cleanTokenFromKeyChain()
                    self.goToSplashViewController()
                }
            ] )
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
}
