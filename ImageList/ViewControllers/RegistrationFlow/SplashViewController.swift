//
//  SplashViewController.swift
//  ImageList
//
//  Created by Александр Зиновьев on 30.01.2023.
//

import UIKit

final class SplashViewController: UIViewController {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .launchScreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Dependency
    private let oAuth2Service: OAuth2ServiceProtocol
       
    private var oAuth2TokenStorage: OAuth2TokenStorageProtocol

    // MARK: - Init (Dependency injection)
    init(
        oAuth2Service: OAuth2ServiceProtocol,        
        oAuth2TokenStorage: OAuth2TokenStorageProtocol
    ) {
        self.oAuth2Service = oAuth2Service
        self.oAuth2TokenStorage = oAuth2TokenStorage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
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
        
        if oAuth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            let authViewController = AuthViewController(delegate: self)
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBar = TabBarController()
        window.rootViewController = tabBar
    }
}

// MARK: -
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
                UIBlockingProgressHUD.dismiss()
                self.oAuth2TokenStorage.token = token
                self.switchToTabBarController()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                vc.openAlert(
                    title: "Что то пошло не так(",
                    message: "Не удалось войти в систему",
                    alertStyle: .alert,
                    actionTitles: ["ОК"],
                    actionStyles: [.cancel],
                    actions: [nil]
                )
            }
        }
    }
}
