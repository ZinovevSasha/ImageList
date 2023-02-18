//
//  WebViewViewController.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.01.2023.
//

import UIKit
import WebKit

/*
"""
 WebViewViewController tell his delegate
(any who conform WebViewViewControllerDelegate)
in our case AuthViewController that we catch code
or failed to do that__
"
If the user accepts the request,
the user will be redirected to the redirect_uri,
with the authorization code in the code query parameter.
"
"""
 */

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    )
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    @objc private var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(.backWebView, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressViewStyle = .default
        progressView.tintColor = .myBackground
        return progressView
    }()
    
    // MARK: - Dependency
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Init (Dependency injection)
    init(delegate: WebViewViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        webView.load(authScreen())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObserver()
    }
    
    func authScreen(_ auth: UnsplashRequests = .authentication) -> URLRequest {
        auth.request
    }
    
    func addObserver() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new]) { [weak self] _, change in
                guard let self = self else { return }
                guard let value = change.newValue else { return }
                self.updateProgress(estimatedProgress: value)
        }
    }
    
    private func updateProgress(estimatedProgress: Double) {
        progressView.progress = Float(estimatedProgress)
        progressView.isHidden = (webView.estimatedProgress - 0.745) >= 0.0001
    }
    
    @objc private func backButtonTapped() {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

// MARK: - UI
extension WebViewViewController {
    private func setView() {
        view.backgroundColor = .white
        view.addSubviews(webView, backButton, progressView)
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        progressView.progress = 0.05
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),

            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: backButton.bottomAnchor)
        ])
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction.request.url) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            // If code is nil what to do?
            // Or no internet connection?
            decisionHandler(.allow)
        }
    }
    
    private func code(from url: URL?) -> String? {
        // navigationAction.navigationType == .formSubmitted
        if
            let url = url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" }
            ) {
            return codeItem.value
        } else {
            return nil
        }
    }
}
