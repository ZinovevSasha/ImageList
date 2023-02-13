//
//  SplashViewController.swift
//  ImageList
//
//  Created by Александр Зиновьев on 30.01.2023.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(
        _ vc: AuthViewController,
        didAuthenticateWithCode code: String
    )
}

final class SplashViewController: UIViewController {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .launchScreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Dependency
    private let oAuth2Service: OAuth2ServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageService
    private var oAuth2TokenStorage: OAuth2TokenStorageProtocol

    // MARK: - Init (Dependency injection)
    init(
        oAuth2Service: OAuth2ServiceProtocol,
        profileService: ProfileServiceProtocol,
        profileImageService: ProfileImageService,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol
    ) {
        self.oAuth2Service = oAuth2Service
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.oAuth2TokenStorage = oAuth2TokenStorage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    deinit {
        print("deinit... \(String(describing: self))")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
    }
    
    private func setView() {
        imageView.center = view.center
        view.backgroundColor = .myBlack
        view.addSubview(imageView)
    }
            
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oAuth2TokenStorage.token {
            UIBlockingProgressHUD.show()
            fetchProfile()
        } else {
            let authViewController = AuthViewController(delegate: self)
            authViewController.modalPresentationStyle = .fullScreen
            authViewController.modalTransitionStyle = .crossDissolve
            present(authViewController, animated: true)
        }
    }
    
    private func switchToTabBarController(with profile: Profile?) {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBar = TabBarViewController(profileInfo: profile)
        window.rootViewController = tabBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(
        _ vc: AuthViewController,
        didAuthenticateWithCode code: String
    ) {
        UIBlockingProgressHUD.show()
        fetchAuthToken(auth: vc, code: code)
    }
    
    private func fetchAuthToken(auth vc: AuthViewController, code: String) {
        oAuth2Service.fetchOAuthToken(withCode: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.oAuth2TokenStorage.token = token
                self.fetchProfile()
            case .failure(let failure):
                print(failure)
                UIBlockingProgressHUD.dismiss()
                vc.showAlert(
                    title: "Что то пошло не так(",
                    message: "Не удалось войти в систему",
                    actionTitle: "ОК"
                )
            }
        }
    }
    
    private func fetchProfile() {
        profileService.fetchProfile() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.fetchProfileImageUrl(username: profile.username)
                self.switchToTabBarController(with: profile)
            case .failure(let error):
                print(error)
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func fetchProfileImageUrl(username: String) {
        ProfileImageService.shared.fetchProfileImageUrl(
            username: username) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print(error)
                }
        }
    }
}
