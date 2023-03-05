import UIKit

/*
"""
AuthViewControllerDelegate tell his delegate
(any who conform AuthViewControllerDelegate)
in our case SplashViewController that we catch code __
"
If the user accepts the request,
the user will be redirected to the redirect_uri,
with the authorization code in the code query parameter.
"
"""
*/

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(
        _ vc: AuthViewController,
        didAuthenticateWithCode code: String
    )
}

final class AuthViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private var enterButton: UIButton = {
        let button = UIButton()
        button.cornerRadius = 16
        button.backgroundColor = .white
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.myBlack, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.welcomeScreenImage
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    // MARK: Delegate
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Init
    init(delegate: AuthViewControllerDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setConstraint()
    }
    
    // MARK: - Transition
    @objc private func enterButtonTapped() {
        let webViewController = WebViewViewController(delegate: self)
        webViewController.modalPresentationStyle = .fullScreen
        present(webViewController, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
}

// MARK: - UI
private extension AuthViewController {
    func setView() {
        view.addSubviews(image, enterButton)
        view.backgroundColor = .myBlack
        image.center = view.center
        enterButton.addTarget(
            self, action: #selector(enterButtonTapped), for: .touchUpInside)
    }
    
    func setConstraint() {
        NSLayoutConstraint.activate([
            // Image
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Button
            enterButton.heightAnchor.constraint(
                equalToConstant: 48),
            enterButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            enterButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16),
            enterButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -90)
        ])
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        enterButton.backgroundColor = .myWhite50
        vc.dismiss(animated: true)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
