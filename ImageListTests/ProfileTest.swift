//
//  ProfileTest.swift
//  ImageListTests
//
//  Created by Александр Зиновьев on 13.03.2023.
//

import XCTest
@testable import ImageList

final class ProfileTest: XCTestCase {
    func testProfileControllerCallsViewDidLoad() {
        // Given        
        let profilePresenterSpy = ProfilePresenterSpy()
        let profileViewController = ProfileViewController()
        profileViewController.presenter = profilePresenterSpy
        profilePresenterSpy.view = profileViewController
       
        // When
        _ = profileViewController.view
        
        // Then
        XCTAssertTrue(profilePresenterSpy.viewDidLoadIsCalled)
    }
    
    func testPresenterCallFunctionsWhenExitButtonTapped() {
        // Given
        let oAuthTokenStorageSpy = OAuthTokenStorageSpy()
        let webViewCleanerSpy = WebViewCleanerSpy()
        let profilePresenter = ProfilePresenter(
            view: nil,
            profileImageService: ProfileImageServiceMock(),
            profileService: ProfileServiceMock(),
            oAuth2TokenStorage: oAuthTokenStorageSpy,
            webViewCleaner: webViewCleanerSpy
        )
        let profileViewController = ProfileViewControllerSpy(presenter: profilePresenter)
        profilePresenter.view = profileViewController

        // When person wants to leave account
        profileViewController.presenter.exitButtonDidTapped()
        
        // Then
            // token and webView data must be removed
        XCTAssertNil(oAuthTokenStorageSpy.tokenSetToNil)
        XCTAssertTrue(webViewCleanerSpy.cleanIsCalled)
            // Splash controller must be presented
        XCTAssertTrue(profileViewController.goToSplashViewControllerFunctionCalled)
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadIsCalled = false
    
    func viewDidLoad() {
        viewDidLoadIsCalled = true
    }
    
    func exitButtonDidTapped() {}
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol
    var goToSplashViewControllerFunctionCalled = false
    
    init(presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
    }
    
    func goToSplashViewController() {
        print("goToSplashViewController called fake")
        goToSplashViewControllerFunctionCalled = true
    }
    
    func configureUI(with viewModel: ProfileViewModel) {
            
    }
    
    func animateGradientView() {
            
    }
    
    func removeAllAnimationsFromGradientView() {
            
    }
    
    func removeGradientViewFromSuperLayer() {
            
    }
}
final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    func fetchProfileImageUrl(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("fetchProfileImageUrl fake")
    }
    
    var avatarUrl: String?
}

final class ProfileServiceMock: ProfileServiceProtocol {
    func fetchProfile(completion: @escaping (Result<ImageList.Profile, Error>) -> Void) {
        print("fetchProfile fake")
    }
}

final class WebViewCleanerSpy: WebViewCookieDataCleanerProtocol {
    var cleanIsCalled = false
    
    func clean() {
        print("WebViewCleanerSpy called fake")
        cleanIsCalled = true
    }
}

final class OAuthTokenStorageSpy: OAuth2TokenStorageProtocol {
    var tokenSetToNil: String? = "secretToken qwe123456"
    
    var token: String? {
        get {
            return tokenSetToNil
        }
        set {
            print("tokenSetToNil fake")
            tokenSetToNil = newValue
        }
    }
}
