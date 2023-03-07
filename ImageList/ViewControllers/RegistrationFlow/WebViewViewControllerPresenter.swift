//
//  WebViewViewControllerPresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 05.03.2023.
//

import Foundation

protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewViewPresenterProtocol { get }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHiden: Bool)
}

final class WebViewViewPresenter {
    weak var view: WebViewViewControllerProtocol?
    private let authHelper: UnsplashAuthHelperProtocol
    
    init(
        view: WebViewViewControllerProtocol?,
        authHelper: UnsplashAuthHelperProtocol
    ) {
        self.view = view
        self.authHelper = authHelper
    }
    
    private func shouldHideProgress(for value: Double) -> Bool {
        (value - 0.745) >= 0.0001
    }
}

extension WebViewViewPresenter: WebViewViewPresenterProtocol {
    func viewDidLoad() {
        view?.load(request: authHelper.authRequest())
        didUpdateProgressValue(0.05)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        view?.setProgressValue(Float(newValue))
        let shouldHideProgress = shouldHideProgress(for: newValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func code(from url: URL?) -> String? {
        authHelper.code(from: url)
    }
}
