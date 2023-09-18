//
//  ProfilePresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 10.03.2023.
//

import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get }
    func viewDidLoad()
    func exitButtonDidTapped()
}

enum ProfilePersonalDataState {
    case loading
    case error
    case finished(Data?)
}

final class ProfilePresenter {
    // MARK: - Dependency
    weak var view: ProfileViewControllerProtocol?
    private let profileImageService: ProfileImageServiceProtocol?
    private let profileService: ProfileServiceProtocol?
    private var oAuth2TokenStorage: OAuth2TokenStorageProtocol?
    private let webViewCleaner: WebViewCookieDataCleanerProtocol?
    private let imageLoader: ImageLoaderProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var profile: Profile?
    
    // MARK: - Init (Dependency injection)
    init(
        view: ProfileViewControllerProtocol?,
        profileImageService: ProfileImageServiceProtocol?,
        profileService: ProfileServiceProtocol?,
        oAuth2TokenStorage: OAuth2TokenStorageProtocol?,
        webViewCleaner: WebViewCookieDataCleanerProtocol?,
        imageLoader: ImageLoaderProtocol?
    ) {
        self.view = view
        self.profileImageService = profileImageService
        self.profileService = profileService
        self.oAuth2TokenStorage = oAuth2TokenStorage
        self.webViewCleaner = webViewCleaner
        self.imageLoader = imageLoader
        
        addObserver()
        fetchProfile()
    }
    
    // MARK: - Private
    private var profileState: ProfilePersonalDataState = .loading {
        didSet {
            configureImageState()
        }
    }
    
    private func configureImageState() {
        switch profileState {
        case .loading:
            view?.animateGradientView()
        case .error:
            view?.removeAllAnimationsFromGradientView()
        case .finished(let data):
            guard
                let profile = profile,
                let data = data
            else {
                return
            }
            
            let viewModel = convertToViewModel(data, profile: profile)
            view?.removeAllAnimationsFromGradientView()
            view?.removeGradientViewFromSuperLayer()
            view?.show(viewModel)
        }
    }
    
    private func convertToViewModel(_ data: Data, profile: Profile) -> ProfileViewModel {
        return ProfileViewModel(
            portraitImageData: data,
            name: profile.name,
            email: profile.loginName,
            greeting: profile.bio
        )
    }
    
    private func fetchProfile() {
        profileService?.fetchProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                self.fetchProfileImageUrl(username: profile.username)
            case .failure:
                self.profileState = .error
            }
        }
    }
    
    private func fetchProfileImageUrl(username: String) {
        profileImageService?
            .fetchProfileImageUrl(username: username) { [weak self] result in
                guard case .failure = result else { return }
                self?.profileState = .error
            }
    }
    
    private func updateAvatarImage(url: String?) {
        profileState = .loading
        guard let avatarURLString = url,
            let url = URL(string: avatarURLString)
        else {
            return
        }
        imageLoader?.downloadImage(url) { [weak self] result in
            switch result {
            case .success(let result):
                self?.profileState = .finished(result)
            case .failure:
                self?.profileState = .error
            }
        }
    }
    
    private func addObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main) { [weak self] notification in
                    guard let self = self else { return }
                    
                    let url = notification.userInfo?[UserInfo.url.rawValue] as? String
                    self.updateAvatarImage(url: url)
            }
    }
    
    private func cleanWebViewSavedData() {
        webViewCleaner?.clean()
    }
    
    private func cleanTokenFromKeyChain() {
        oAuth2TokenStorage?.token = nil
    }
}

extension ProfilePresenter: ProfilePresenterProtocol {
    func viewDidLoad() {
        updateAvatarImage(url: profileImageService?.avatarUrl)
    }
    
    func exitButtonDidTapped() {
        cleanWebViewSavedData()
        cleanTokenFromKeyChain()
        view?.goToSplashViewController()
    }
}
