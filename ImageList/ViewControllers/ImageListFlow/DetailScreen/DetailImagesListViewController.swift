import UIKit

protocol DetailImageListViewControllerProtocol: AnyObject {
    var presenter: DetailImageListPresenterProtocol { get }
    func startSpinner()
    func stopSpinner()
    func showAlertAndMaybeTryAgainWith(url: URL)
    func hideScribble()
    func didReceiveImage(_ image: UIImage)
}

final class DetailImagesListViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private let photoImageView: UIImageView = {
        let image = UIImageView()
        image.alpha = 0
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let scribbleImageView: UIImageView = {
        let image = UIImageView(image: .scribble)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(.backward, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let shareButton: UIButton = {
        let shareButton = UIButton()
        shareButton.setImage(.share, for: .normal)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        return shareButton
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private var scrollView = DetailScrollView()
    lazy var presenter: DetailImageListPresenterProtocol = DetailImageListPresenter(
        view: self
    )
    // MARK: - Public
    public func configure(with stringURL: String) {
        guard let url = URL(string: stringURL) else { return }
        presenter.fetchImage(with: url)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setConstraints()
    }
    
    @objc private func goBack() {
        dismiss(animated: true)
    }
    
    @objc private func share() {
        guard let image = photoImageView.image else { return }
        let activityController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityController, animated: true, completion: nil)
    }
}

// MARK: - UI
private extension DetailImagesListViewController {
    func setViews() {
        view.backgroundColor = .myBlack
        scrollView.setImageView(photoImageView)
        view.addSubviews(scrollView, backButton, shareButton, spinner, scribbleImageView)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            
            // backButton
            backButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 17),
            backButton.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: 60),
            
            // shareButton
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // spinner
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // scribble
            scribbleImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scribbleImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension DetailImagesListViewController: DetailImageListViewControllerProtocol {
    func didReceiveImage(_ image: UIImage) {
        photoImageView.image = image
        
        view.layoutIfNeeded()
        scrollView.rescaleImage()
        scrollView.layoutIfNeeded()
        scrollView.centerImage()
        
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.photoImageView.alpha = 1
        }
    }
    
    func hideScribble() {
        scribbleImageView.isHidden = true
    }
    
    func startSpinner() {
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        spinner.stopAnimating()
    }
    
    func showAlertAndMaybeTryAgainWith(url: URL) {
        showAlert(
            title: "Что то пошло не так(",
            message: "Попробовать ещё раз?",
            actions: [
                Action(title: "Не надо", style: .default, handler: nil),
                Action(title: "Повторить", style: .default) { [weak self] _ in
                    self?.presenter.fetchImage(with: url)
                }
            ]
        )
    }
}
