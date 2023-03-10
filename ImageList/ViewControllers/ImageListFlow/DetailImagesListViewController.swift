import UIKit

protocol DetailImageListViewControllerProtocol: AnyObject {
    var presenter: DetailImageListPresenterProtocol { get }
    func startSpinner()
    func stopSpinner()
    func showAlert(url: URL)
    func hideScribble()
    func didReceiveImageData(_ imageData: UIImage)
    func scrollViewSetScale(_ scale: CGFloat)
    func scrollViewLayoutIfNeeded() -> CGSize
    func scrollViewSetContentOffset(offset: CGPoint)
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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 0.7
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    lazy var presenter: DetailImageListPresenterProtocol = DetailImageListPresenter(view: self
    )
    // MARK: - Public
    public func configure(with stringURL: String) {
        guard let url = URL(string: stringURL) else { return }
        
        presenter.fetchImage(with: url)
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
    
    @objc func doubleTapAction(_ recognizer: UITapGestureRecognizer) {
        let imageViewSize = photoImageView.frame.size
        let scale: CGFloat = 1.5
        let point = recognizer.location(in: photoImageView)
        let zoomRect = CGRect(
            x: point.x - imageViewSize.width / (2 * scale),
            y: point.y - imageViewSize.height / (2 * scale),
            width: imageViewSize.width / scale,
            height: imageViewSize.height / scale
        )
        print(zoomRect.minX, imageViewSize.width)
        print(zoomRect.minY, imageViewSize.height)
        print(zoomRect)
        scrollView.zoom(to: zoomRect, animated: true)
    }
    
    func centerImageAfterZooming(_ scrollViewBoundsSize: UIScrollView, _ imageViewSize: CGSize) {
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageViewSize
        
        let horizontalPadding = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalPadding = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        )
    }
}

// MARK: - UI
private extension DetailImagesListViewController {
    private func setSubviews() {
        view.backgroundColor = .myBlack
        scrollView.addSubview(photoImageView)
        view.addSubviews(scrollView, backButton, shareButton, spinner, scribbleImageView)
        scrollView.delegate = self
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        addDoubleTapGestureToPhotoImageView()
    }
    
    func addDoubleTapGestureToPhotoImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        tapGesture.numberOfTapsRequired = 2
        photoImageView.addGestureRecognizer(tapGesture)
        photoImageView.isUserInteractionEnabled = true
    }
    
    private func setConstraint() {
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
    func scrollViewSetContentOffset(offset: CGPoint) {
        scrollView.setContentOffset(offset, animated: false)
    }
    
    func scrollViewLayoutIfNeeded() -> CGSize {
        scrollView.layoutIfNeeded()
        return scrollView.contentSize
    }
    
    func scrollViewSetScale(_ scale: CGFloat) {
        scrollView.setZoomScale(scale, animated: false)
    }
    
    func didReceiveImageData(_ image: UIImage) {
//        guard
//            let imageData = imageData,
//            let image = UIImage(data: imageData)
//        else {
//            return
//        }
        
        photoImageView.image = image
        view.layoutIfNeeded()
        presenter.configureImageInScrollview(
            image.size,
            scrollView.bounds.size,
            scrollView.minimumZoomScale,
            scrollView.maximumZoomScale
        )
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
    
    func showAlert(url: URL) {
        showAlert(
            title: "Что то пошло не так(",
            message: "Попробовать ещё раз?",
            actions: [
                Action(title: "Не надо", style: .default, handler: nil),
                Action(
                    title: "Повторить",
                    style: .default) { [weak self] _ in
                        self?.presenter.fetchImage(with: url)
                }
            ]
        )
    }
}

// MARK: - UIScrollViewDelegate
extension DetailImagesListViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Center the image after zooming
        centerImageAfterZooming(scrollView, photoImageView.frame.size)
    }
}
