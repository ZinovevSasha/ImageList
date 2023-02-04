//
//  WebViewViewController.swift
//  ImageList
//
//  Created by Александр Зиновьев on 22.01.2023.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    weak var delegate: WebViewViewControllerDelegate?
    
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
    
    // MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        loadAuthScreen()
    }
    
    private func setUpViews() {
        view.backgroundColor = .white
        view.addSubviews(webView, backButton, progressView)
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        progressView.progress = 0.05
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private func loadAuthScreen() {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize")!
        
        urlComponents.queryItems = [
            URLQueryItem(
                name: "client_id", value: accessKey),
            URLQueryItem(
                name: "redirect_uri", value: redirectURI),
            URLQueryItem(
                name: "response_type", value: "code"),
            URLQueryItem(
                name: "scope", value: accessScope)
        ]
        
        let url = urlComponents.url!
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
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
    
    @objc private func backButtonTapped() {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            // If code is nil what to do?
            // Or no internet connection?
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
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
