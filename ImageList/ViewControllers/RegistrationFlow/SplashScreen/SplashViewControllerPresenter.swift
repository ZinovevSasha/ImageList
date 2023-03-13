//
//  SplashViewControllerPresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 05.03.2023.
//

import Foundation

protocol SplashViewPresenterProtocol {
    var view: SplashViewControllerProtocol? { get }
    func checkIfTokenAvailable()
    func fetchAuthToken(auth vc: AuthViewController, code: String)
}

final class SplashViewPresenter {
    // MARK: - Dependency
    weak var view: SplashViewControllerProtocol?
    private let oAuth2Service: OAuth2ServiceProtocol
    private var oAuth2TokenStorage: OAuth2TokenStorageProtocol
    
    // MARK: - Init (Dependency injection)
    init(
        view: SplashViewControllerProtocol?,
        oAuth2Service: OAuth2ServiceProtocol,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol
    ) {
        self.view = view
        self.oAuth2Service = oAuth2Service
        self.oAuth2TokenStorage = oAuth2TokenStorage
    }
}

extension SplashViewPresenter: SplashViewPresenterProtocol {
    func checkIfTokenAvailable() {
        if oAuth2TokenStorage.token != nil {
            view?.switchToTabBarController()
        } else {
            view?.presentAuthViewController()
        }
    }
    
    func fetchAuthToken(auth vc: AuthViewController, code: String) {
        oAuth2Service.fetchOAuthToken(withCode: code) { [weak self] result in
            guard let self = self else { return }
            self.view?.dismissLoader()
            switch result {
            case .success(let token):
                self.oAuth2TokenStorage.token = token
                self.view?.switchToTabBarController()
            case .failure:
                vc.showAlert(
                    title: "Что то пошло не так(",
                    message: "Не удалось войти в систему",
                    actions: [
                        Action(
                            title: "Ok",
                            style: .cancel,
                            handler: { _ in
                                vc.makeEnterButtonWhite()
                            }
                        )
                    ]
                )
            }
        }
    }
}
