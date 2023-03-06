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
    private var authRequest: UnsplashRequests = .authentication
    
    init(view: WebViewViewControllerProtocol?) {
        self.view = view
    }
    
    private func shouldHideProgress(for value: Double) -> Bool {
        (value - 0.745) >= 0.0001
    }
}

extension WebViewViewPresenter: WebViewViewPresenterProtocol {
    func viewDidLoad() {
        view?.load(request: authRequest.request)
        didUpdateProgressValue(0.05)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        view?.setProgressValue(Float(newValue))
        let shouldHideProgress = shouldHideProgress(for: newValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func code(from url: URL?) -> String? {
        // navigationAction.navigationType == .formSubmitted
        if let url = url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" }) {
            return codeItem.value
        } else {
            return nil
        }
    }
}
