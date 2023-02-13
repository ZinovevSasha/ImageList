import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    )
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class AuthViewController: UIViewController {
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
    
    
    // MARK: - Dependency
    weak var delegate: AuthViewControllerDelegate?
    private var confettiAnimationLayer: ConfettiAnimationEffect?
    
    // MARK: - Init (Dependency injection)
    init(delegate: AuthViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        showConfettiAnimationEffect()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
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
}

// MARK: - UI
extension AuthViewController {
    private func setView() {
        image.center = view.center
        view.backgroundColor = .myBlack
        view.addSubviews(enterButton, image)
        enterButton.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
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
    
    private func showConfettiAnimationEffect() {
        confettiAnimationLayer = ConfettiAnimationEffect(
            view: view,
            colors: [.white],
            position: CGPoint(x: view.center.x, y: -100)
        )
    }
    
    public func showAlert(
        title: String,
        message: String,
        actionTitle: String
    ) {
        let ac = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: actionTitle,
            style: .cancel
        )
        
        ac.addAction(action)
        present(ac, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        vc.dismiss(animated: true)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
