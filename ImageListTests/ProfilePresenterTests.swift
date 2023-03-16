//
//  ProfileTest.swift
//  ImageListTests
//
//  Created by Александр Зиновьев on 13.03.2023.
//

import XCTest
@testable import ImageList

final class ProfilePresenterTests: XCTestCase {
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
            profileImageService: nil,
            profileService: nil,
            oAuth2TokenStorage: oAuthTokenStorageSpy,
            webViewCleaner: webViewCleanerSpy,
            imageLoader: nil
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
    
    func testPresenterStartFetchingOnViewDidLoad() {
        // Given
        let imageLoaderStubSpy = ImageLoaderStub(emulateError: false)
        let profileImageService = ProfileImageServiceMock(emulateError: false)
        let profileServiceMock = ProfileServiceMock(emulateError: false)
        let profileViewModel = ProfileViewModel(portraitImageData: Data(), name: "name", email: "loginName", greeting: "bio")
        
        // When
        let profilePresenter = ProfilePresenter(
            view: nil,
            profileImageService: profileImageService,
            profileService: profileServiceMock,
            oAuth2TokenStorage: nil,
            webViewCleaner: nil,
            imageLoader: imageLoaderStubSpy
        )
        let profileViewController = ProfileViewControllerSpy(presenter: profilePresenter)
        profilePresenter.view = profileViewController
        profilePresenter.viewDidLoad()
        
        // Then
        XCTAssertEqual(imageLoaderStubSpy.fakeURL, "https://unsplash.com/avatarURL")
        XCTAssertTrue(profileViewController.gradientAnimationRemoved)
        XCTAssertTrue(profileViewController.gradientRemovedFromSuperLayer)
        XCTAssertEqual(profileViewController.profileViewModel, profileViewModel)
    }
}

final class ImageLoaderStub: ImageLoaderProtocol {
    var emulateError = false
    var data = Data()
    var fakeURL: String?
    
    init(emulateError: Bool) {
        self.emulateError = emulateError
    }
    
    func downloadImage(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        if emulateError {
            completion(.failure(FakeError.failureToLoad))
        } else {
            fakeURL = url.absoluteString
            completion(.success(data))
        }
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
    // presenter
    var presenter: ProfilePresenterProtocol
    init(presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
    }
    // goToSplashViewController
    var goToSplashViewControllerFunctionCalled = false
    func goToSplashViewController() {
        goToSplashViewControllerFunctionCalled = true
    }
    // show
    var profileViewModel: ProfileViewModel?
    func show(_ viewModel: ImageList.ProfileViewModel) {
        profileViewModel = ProfileViewModel(
            portraitImageData: viewModel.portraitImageData,
            name: viewModel.name,
            email: viewModel.email,
            greeting: viewModel.greeting
        )
    }
    func animateGradientView() {
        
    }
    // removeAllAnimationsFromGradientView
    var gradientAnimationRemoved = false
    func removeAllAnimationsFromGradientView() {
        gradientAnimationRemoved = true
    }
    // removeGradientViewFromSuperLayer
    var gradientRemovedFromSuperLayer = false
    func removeGradientViewFromSuperLayer() {
        gradientRemovedFromSuperLayer = true
    }
}

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    let emulateError: Bool
    
    init(emulateError: Bool) {
        self.emulateError = emulateError
    }
    
    func fetchProfileImageUrl(username: String, completion: @escaping (Result<String, Error>) -> Void) {
    }
    
    var avatarUrl: String? = "https://unsplash.com/avatarURL"
}

final class ProfileServiceMock: ProfileServiceProtocol {
    let emulateError: Bool
    
    init(emulateError: Bool) {
        self.emulateError = emulateError
    }
    
    func fetchProfile(completion: @escaping (Result<ImageList.Profile, Error>) -> Void) {
        if emulateError {
            completion(.failure(FakeError.failureToLoad))
        } else {
            let profile = Profile(
                username: "username",
                name: "name",
                loginName: "loginName",
                bio: "bio"
            )
            completion(.success(profile))
        }
    }
}

enum FakeError: Error {
    case failureToLoad
}

final class WebViewCleanerSpy: WebViewCookieDataCleanerProtocol {
    var cleanIsCalled = false
    func clean() {
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
            tokenSetToNil = newValue
        }
    }
}
