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
        button.cornerRadius = 16
        button.backgroundColor = .white
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.myBlack, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var image: UIButton = {
        let button = UIButton()
        button.setImage(.welcomeScreenImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //    private var image: UIImageView = {
    //        let image = UIImageView()
    //        image.image = UIImage.welcomeScreenImage
    //        image.translatesAutoresizingMaskIntoConstraints = false
    //        return image
    //    }()
    
    private var imageSea: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.sea
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private var spinningCircleView: SpinningCircleView?
    private let transition = CircularTransition()
    
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
        webViewController.transitioningDelegate = self
        webViewController.modalPresentationStyle = .custom
        self.present(webViewController, animated: true)
    }
}

// MARK: - UI
extension AuthViewController {
    private func setView() {
        image.center = view.center
        view.backgroundColor = .myBlack
        
        image.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        view.addSubviews(imageSea, image)
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            // Image
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Button
            //            enterButton.heightAnchor.constraint(
            //                equalToConstant: 48),
            //            enterButton.leadingAnchor.constraint(
            //                equalTo: view.leadingAnchor,
            //                constant: 16),
            //            enterButton.trailingAnchor.constraint(
            //                equalTo: view.trailingAnchor,
            //                constant: -16),
            //            enterButton.bottomAnchor.constraint(
            //                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            //                constant: -90),
            
            imageSea.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageSea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageSea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageSea.heightAnchor.constraint(equalToConstant: view.frame.height * 0.3)
        ])
    }
    
    private func showConfettiAnimationEffect() {
        confettiAnimationLayer = ConfettiAnimationEffect(
            view: view,
            colors: [.white],
            position: CGPoint(x: view.center.x, y: -100)
        )
    }
    
    public func showSpinner() {
        spinningCircleView = SpinningCircleView()
        if let spinningCircleView {
            let origin = CGPoint(x: view.center.x - 75, y: view.center.y - 75)
            spinningCircleView.frame = CGRect(origin: origin, size: CGSize(width: 150, height: 150))
            view.insertSubview(spinningCircleView, belowSubview: image)
            spinningCircleView.animate()
        }
    }
    
    public func hideSpinner() {
        view.subviews.forEach { $0.layer.removeAllAnimations() }
        view.layer.removeAllAnimations()
        view.layoutIfNeeded()
        spinningCircleView?.removeFromSuperview()
        spinningCircleView = nil
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
            style: .cancel) { [weak self] _ in
                self?.enterButton.backgroundColor = .white
        }
        
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
        enterButton.backgroundColor = .myWhite50
        vc.dismiss(animated: true)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = image.center
        transition.circleColor = .white
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = image.center
        transition.circleColor = .black
        return transition
    }
}
