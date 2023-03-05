//
//  SplashViewController.swift
//  ImageList
//
//  Created by Александр Зиновьев on 30.01.2023.
//

import UIKit

protocol SplashViewControllerPresenterProtocol {
    func checkIfTokenAvailable()
    func fetchAuthToken(auth vc: AuthViewController, code: String)
}

final class SplashViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .launchScreen
        return imageView
    }()
    
    // MARK: - Presenter (will be initialized at first call)
    lazy private var presenter = SplashViewControllerPresenter(
        view: self,
        oAuth2Service: OAuth2Service(),
        oAuth2TokenStorage: OAuth2TokenStorage()
    )
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter.checkIfTokenAvailable()
    }
    
    private func setView() {
        view.backgroundColor = .myBlack
        view.addSubview(imageView)
        imageView.center = view.center
    }
}

extension SplashViewController: SplashViewControllerProtocol {
    func presentAuthViewController() {
        let authViewController = AuthViewController(delegate: self)
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    func switchToTabBarController() {
        if let window = UIApplication.shared.windows.first {
            let tabBar = TabBarController()
            window.rootViewController = tabBar
        } else {
            fatalError("Invalid Configuration")
        }
    }
    
    func dismissLoader() {
        UIBlockingProgressHUD.dismiss()
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(
        _ vc: AuthViewController,
        didAuthenticateWithCode code: String
    ) {
        UIBlockingProgressHUD.show()
        presenter.fetchAuthToken(auth: vc, code: code)
    }
}
