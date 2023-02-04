//
//  SplashViewController.swift
//  ImageList
//
//  Created by Александр Зиновьев on 30.01.2023.
//

import UIKit
import ProgressHUD

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

    // Dependencies
    private let oAuth2Service: OAuth2ServiceProtocol = OAuth2Service()
    private var oAuth2TokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .myBlack
        view.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.center = view.center
        //addConstraints()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oAuth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            let authViewController = AuthViewController()
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = TabBarViewController()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(
        _ vc: AuthViewController,
        didAuthenticateWithCode code: String
    ) {
        ProgressHUD.show()
        fetchAuthToken(auth: vc, code: code)
    }
    
    private func fetchAuthToken(auth vc: AuthViewController, code: String) {
        oAuth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.oAuth2TokenStorage.token = token
                ProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure(let failure):
                print("aaaaaaaaaaaaaaaaa\(failure)")
                vc.disableEnableEnterButton()
                //TODO: - failure
            }
        }
    }
}
