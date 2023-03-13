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

protocol WebViewControllerDelegate: AnyObject {
    func webViewViewController(
        _ vc: WebViewController,
        didAuthenticateWithCode code: String
    )
    func webViewViewControllerDidCancel(_ vc: WebViewController)
}

protocol WebViewPresenterProtocol {
    var view: WebViewControllerProtocol? { get }
    func viewDidLoad()
    func code(from url: URL?) -> String?
    func didUpdateProgressValue(_ newValue: Double)
}

final class WebViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    
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
    
    // MARK: Delegate
    weak var delegate: WebViewControllerDelegate?
    
    // MARK: Presenter
    lazy var presenter: WebViewPresenterProtocol = WebViewViewPresenter(
        view: self,
        authHelper: AuthHelper(
            UnsplashAuthConfiguration.standard,
            requestBuilder: RequestBuilder()
        )
    )
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Init
    init(delegate: WebViewControllerDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        setTargets()
        presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObserver()
    }
    
    func addObserver() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new]) { [weak self] _, change in
                guard let self = self,
                    let newValue = change.newValue
                else {
                    return
                }
                self.presenter.didUpdateProgressValue(newValue)
        }
    }
    
    @objc private func backButtonTapped() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

extension WebViewController: WebViewControllerProtocol {
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHiden: Bool) {
        progressView.isHidden = isHiden
    }
}

// MARK: - UI
private extension WebViewController {
    func setViews() {
        view.addSubviews(webView, backButton, progressView)
        view.backgroundColor = .white
        webView.backgroundColor = .white
        webView.navigationDelegate = self
    }
    
    func setTargets() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    func setConstraints() {
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
extension WebViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter.code(from: url)
        } else {
            return nil
        }
    }
}
