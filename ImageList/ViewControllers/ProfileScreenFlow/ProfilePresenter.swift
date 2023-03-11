//
//  ProfilePresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 10.03.2023.
//

import WebKit
import Foundation
import Kingfisher

protocol ProfilePresenterProtocol {
    func viewDidLoad()
    func exitButtonDidTapped()
    func changeStateToLoading()
}

enum ProfilePersonalDataState {
    case loading
    case error
    case finished(Data?)
}

final class ProfilePresenter {
    // MARK: - Dependency
    weak var view: ProfileViewControllerProtocol?
    private let profileImageService: ProfileImageServiceProtocol
    private let profileService: ProfileServiceProtocol
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var profile: Profile?
    
    // MARK: - Init (Dependency injection)
    init(
        view: ProfileViewControllerProtocol?,
        profileImageService: ProfileImageServiceProtocol,
        profileService: ProfileServiceProtocol
    ) {
        self.view = view
        self.profileImageService = profileImageService
        self.profileService = profileService
        
        addObserver()
        fetchProfile()
    }
    
    var profileState: ProfilePersonalDataState = .loading {
        didSet {
            configureImageState()
        }
    }
    
    private func configureImageState() {
        switch profileState {
        case .loading:
            view?.showGradientView()
            view?.animateGradientView()
        case .error:
            view?.stopAnimatingGradientView()
        case .finished(let image):
            view?.stopAnimatingGradientView()
            view?.hideGradientView()
            
            guard
                let profile = profile,
                let image = image
            else {
                return
            }
            
            let profileViewModel = ProfileViewModel(
                portraitImageData: image,
                name: profile.name,
                email: profile.loginName,
                greeting: profile.bio)
            
            view?.configureUI(with: profileViewModel)
        }
    }
    
    private func fetchProfile() {
        profileService.fetchProfile { [weak self] result in
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
        profileImageService
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
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            switch result {
            case .success(let result):
                self?.profileState = .finished(result.data())
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
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record]) {}
            }
        }
    }
    
    private func cleanTokenFromKeyChain() {
        OAuth2TokenStorage().token = nil
    }
}

extension ProfilePresenter: ProfilePresenterProtocol {
    func changeStateToLoading() {
        profileState = .loading
    }
    
    func exitButtonDidTapped() {
        cleanWebViewSavedData()
        cleanTokenFromKeyChain()
        view?.goToSplashViewController()
    }
    
    func viewDidLoad() {
        updateAvatarImage(url: profileImageService.avatarUrl)
    }
}
