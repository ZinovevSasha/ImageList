import UIKit
import Kingfisher

class DetailImagesListViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private let photoImageView: UIImageView = {
        let image = UIImageView()
        image.alpha = 0
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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.2
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    // MARK: - Public
    public func configure(with stringURL: String) {
        guard let url = URL(string: stringURL) else { return }
        fetchImage(with: url)
    }
    
    var imageState: DetailImageState = .loading {
        didSet {
            configureImageState()
        }
    }
    
    private func fetchImage(with url: URL) {
        imageState = .loading
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                self.imageState = .finished(result.image)
            case .failure:
                self.imageState = .error(url)
            }
        }
    }
    
    enum DetailImageState {
        case loading
        case error(URL)
        case finished(UIImage)
    }
    
    private func configureImageState() {
        switch imageState {
        case .loading:
            spinner.startAnimating()
        case .error(let url):
            spinner.stopAnimating()
            showAlert(
                title: "Что то пошло не так(",
                message: "Попробовать ещё раз?",
                actions: [
                    Action(title: "Не надо", style: .default, handler: nil),
                    Action(
                        title: "Повторить",
                        style: .default,
                        handler: { [weak self] _ in self?.fetchImage(with: url) }
                    )
                ]
            )
        case .finished(let image):
            scribbleImageView.isHidden = true
            spinner.stopAnimating()
            photoImageView.image = image
            rescaleAndCenterImageInScrollView(image)
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.photoImageView.alpha = 1
            }
        }
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setConstraint()
    }
    
    private func rescaleAndCenterImageInScrollView(_ image: UIImage) {
        let imageSize = image.size
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
       
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let theoreticalScale = max(hScale, vScale)
        let scale = min(maxZoomScale, max(minZoomScale, theoreticalScale))
        scrollView.setZoomScale(scale, animated: false)
        
        scrollView.layoutIfNeeded()
        let newContentsSize = scrollView.contentSize
        let x = (newContentsSize.width - visibleRectSize.width) / 2
        let y = (newContentsSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: true)
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
        self.present(activityController, animated: true, completion: nil)
    }
}

// MARK: - UI
private extension DetailImagesListViewController {
    private func setSubviews() {        
        view.backgroundColor = .myBlack
        scrollView.delegate = self
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
    }
    
    private func setConstraint() {
        scrollView.addSubview(photoImageView)
        view.addSubviews(scrollView, backButton, shareButton, spinner, scribbleImageView)
        
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

// MARK: - UIScrollViewDelegate
extension DetailImagesListViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
}
