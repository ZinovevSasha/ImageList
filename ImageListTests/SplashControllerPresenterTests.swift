//
//  SplashControllerPresenterTests.swift
//  ImageListTests
//
//  Created by Александр Зиновьев on 15.03.2023.
//

import XCTest
@testable import ImageList

final class SplashControllerPresenterTests: XCTestCase {
    func testPresenterFindsTokenAndGoToTabBar() {
        // When
        let oAuth2TokenStorageMock = OAuth2TokenStorageMock(withToken: "token")
        let splashPresenter = SplashViewPresenter(
            view: nil,
            oAuth2Service: nil,
            oAuth2TokenStorage: oAuth2TokenStorageMock
        )
        let view = SplashViewControllerSpy(presenter: splashPresenter)
        splashPresenter.view = view
        // When
        splashPresenter.viewDidAppear()
        
        // Then
        XCTAssertTrue(view.switchToTabBarControllerCalled)
        XCTAssertFalse(view.presentAuthViewControllerCalled)
    }
    
    func testPresenterFailsToFindsTokenAndGoToAuthScreen() {
        // When
        let oAuth2TokenStorageMock = OAuth2TokenStorageMock(withToken: nil)
        let splashPresenter = SplashViewPresenter(
            view: nil,
            oAuth2Service: nil,
            oAuth2TokenStorage: oAuth2TokenStorageMock
        )
        let view = SplashViewControllerSpy(presenter: splashPresenter)
        splashPresenter.view = view
        // When
        splashPresenter.viewDidAppear()
        
        // Then
        XCTAssertFalse(view.switchToTabBarControllerCalled)
        XCTAssertTrue(view.presentAuthViewControllerCalled)
    }
    
    func testOAuthTokenStorageSavesTokenAndPresenterProceedToTabBar () {
        // When
        let oAuth2TokenStorageMock = OAuth2TokenStorageMock(withToken: nil)
        let oAuth2ServiceMock = OAuth2ServiceMock(simulateError: false)
        let splashPresenter = SplashViewPresenter(
            view: nil,
            oAuth2Service: oAuth2ServiceMock,
            oAuth2TokenStorage: oAuth2TokenStorageMock
        )
        let view = SplashViewControllerSpy(presenter: splashPresenter)
        splashPresenter.view = view
        // When
        splashPresenter.fetchAuthToken(auth: nil, code: "code")
        
        // Then
        XCTAssertTrue(view.dismissLoaderCalled)
        XCTAssertEqual(oAuth2TokenStorageMock.setToken, "Token")
        XCTAssertTrue(view.switchToTabBarControllerCalled)
    }
    
    func testOAuthServiceFailsToFetchTokenAndAuthScreenShowsAlert() {
        // When
        let oAuth2TokenStorageMock = OAuth2TokenStorageMock(withToken: nil)
        let oAuth2ServiceMock = OAuth2ServiceMock(simulateError: true)
        let authControllerSpy = AuthViewControllerSpy()
        let splashPresenter = SplashViewPresenter(
            view: nil,
            oAuth2Service: oAuth2ServiceMock,
            oAuth2TokenStorage: oAuth2TokenStorageMock
        )
        let view = SplashViewControllerSpy(presenter: splashPresenter)
        splashPresenter.view = view
        // When
        splashPresenter.fetchAuthToken(auth: authControllerSpy, code: "code")
        
        // Then
        XCTAssertTrue(view.dismissLoaderCalled)
        XCTAssertNil(oAuth2TokenStorageMock.setToken)
        XCTAssertTrue(authControllerSpy.showAlertCalled)
    }
}

final class SplashViewControllerSpy: SplashViewControllerProtocol {
    var presenter: ImageList.SplashViewPresenterProtocol
    init(presenter: ImageList.SplashViewPresenterProtocol) {
        self.presenter = presenter
    }
    // switchToTabBarController
    var switchToTabBarControllerCalled = false
    func switchToTabBarController() {
        switchToTabBarControllerCalled = true
    }
    // presentAuthViewController
    var presentAuthViewControllerCalled = false
    func presentAuthViewController() {
        presentAuthViewControllerCalled = true
    }
    // dismissLoader
    var dismissLoaderCalled = false
    func dismissLoader() {
        dismissLoaderCalled = true
    }
}

final class OAuth2TokenStorageMock: OAuth2TokenStorageProtocol {
    let tokenToReturn: String?
    var setToken: String?
    
    init(withToken: String?) {
        self.tokenToReturn = withToken
    }
    
    var token: String? {
        get {
            return tokenToReturn
        }
        set {
            setToken = newValue
        }
    }
}

final class OAuth2ServiceMock: OAuth2ServiceProtocol {
    var simulateError: Bool
    init(simulateError: Bool) {
        self.simulateError = simulateError
    }
    func fetchOAuthToken(withCode code: String, completion: @escaping (Result<String, Error>) -> Void) {
        if simulateError {
            completion(.failure(FakeError.failureToLoad))
        } else {
            completion(.success("Token"))
        }
    }
}

final class AuthViewControllerSpy: AuthViewControllerProtocol {
    var showAlertCalled = false
    func showAlert() {
        showAlertCalled = true
    }
}
