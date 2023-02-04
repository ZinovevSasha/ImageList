import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    )
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

protocol AuthViewControllerProtocol {
    func disableEnableEnterButton()
}

final class AuthViewController: UIViewController, AuthViewControllerProtocol {
    private var enterButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
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
    
    // MARK: - Dependencies
    public weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        enterButton.addTarget(
            self,
            action: #selector(enterButtonTapped),
            for: .touchUpInside
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setConstraint()
    }
    
    @objc private func enterButtonTapped() {
        let webViewController = WebViewViewController()
        webViewController.delegate = self
        webViewController.modalPresentationStyle = .fullScreen
        present(webViewController, animated: true)
    }
    
    private func setViews() {
        image.center = view.center
        view.backgroundColor = .myBlack
        view.addSubviews(enterButton, image)
    }
    
    private func setConstraint() {
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
    
    func disableEnableEnterButton() {
        enterButton.isEnabled.toggle()
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        disableEnableEnterButton()
        vc.dismiss(animated: true)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
