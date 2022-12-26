import UIKit

final class WelcomeViewController: UIViewController {
    private var enterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.font = .boldSFPro17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.welcomeScreenImage
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        view.addSubview(enterButton)
        view.addSubview(image)
        createConstraints()
        enterButton.addTarget(
            self,
            action: #selector(enterButtonTapped),
            for: .touchUpInside)
    }
    
    @objc private func enterButtonTapped() {
        let tabBarController = TabBarViewController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: false)
        
        AuthManager.shared.isSignedIn = true
    }
    
    private func createConstraints() {
        NSLayoutConstraint.activate([
            // Image
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Button
            enterButton.heightAnchor.constraint(equalToConstant: 60),
            enterButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16),
            enterButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16),
            enterButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -124)
        ])
    }
}
