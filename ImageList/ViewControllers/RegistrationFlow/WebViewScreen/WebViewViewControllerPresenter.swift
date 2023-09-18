//
//  WebViewViewControllerPresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 05.03.2023.
//

import Foundation

protocol WebViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol { get }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHiden: Bool)
}

final class WebViewViewPresenter {
    weak var view: WebViewControllerProtocol?
    private let authHelper: AuthHelperProtocol
    
    init(
        view: WebViewControllerProtocol?,
        authHelper: AuthHelperProtocol
    ) {
        self.view = view
        self.authHelper = authHelper
    }
    
    // Helper function
    private func shouldHideProgress(for value: Double) -> Bool {
        (value - 0.745) >= 0.0
    }
}

extension WebViewViewPresenter: WebViewPresenterProtocol {
    func viewDidLoad() {
        didUpdateProgressValue(0.05)
        guard let authRequest = authHelper.authRequest() else { return }
        view?.load(request: authRequest)
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
