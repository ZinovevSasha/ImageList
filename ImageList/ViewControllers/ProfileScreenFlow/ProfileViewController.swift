import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol { get }
    func goToSplashViewController()
    func configureUI(with viewModel: ProfileViewModel)
    func animateGradientView()
    func removeAllAnimationsFromGradientView()
    func removeGradientViewFromSuperLayer()
}

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
    
    private let gradientView = ProfileGradientView()
    
    lazy var presenter: ProfilePresenterProtocol = ProfilePresenter(
        view: self,
        profileImageService: ProfileImageService(requests: UnsplashRequest()),
        profileService: ProfileService(requests: UnsplashRequest()),
        oAuth2TokenStorage: OAuth2TokenStorage(),
        webViewCleaner: WebViewCookieDataCleaner()
    )
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        setTargets()
        presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if nameLabel.text == nil,
            portraitImage.image == nil,
            emailLabel.text == nil {
            animateGradientView()
        }
    }
    
    @objc private func exitButtonTapped() {
        showAlert(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            actions: [
                Action(title: "Нет", style: .cancel, handler: nil),
                Action(title: "Да", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.presenter.exitButtonDidTapped()
                }
            ]
        )
    }
}

// MARK: - UI
extension ProfileViewController {
    private func setViews() {
        view.backgroundColor = .myBlack
        view.addSubviews(portraitImage, exitButton, verticalStackView, gradientView)
        [nameLabel, emailLabel, helloLabel]
            .forEach { verticalStackView.addArrangedSubview($0) }
        gradientView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setTargets() {
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
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

extension ProfileViewController: ProfileViewControllerProtocol {
    func animateGradientView() {
        gradientView.animate()
    }
    
    func removeAllAnimationsFromGradientView() {
        gradientView.removeAllAnimations()
    }
    
    func removeGradientViewFromSuperLayer() {
        gradientView.removeFromSuperLayer()
    }
    
    func configureUI(with model: ProfileViewModel) {
        portraitImage.image = UIImage(data: model.portraitImageData)
        nameLabel.text = model.name
        emailLabel.text = model.email
        helloLabel.text = model.greeting
    }
    
    func goToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Wrong Configuration")
        }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
}
