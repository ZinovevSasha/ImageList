import UIKit

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
                equalToConstant: .enterButtonHeight),
            enterButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: .leftSpacing),
            enterButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -.rightSpacing),
            enterButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -124)
        ])
    }
}

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
