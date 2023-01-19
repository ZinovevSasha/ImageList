import UIKit

class DetailImagesListViewController: UIViewController {
    let image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(.backward, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let shareButton: UIButton = {
        let shareButton = UIButton()
        shareButton.setImage(.share, for: .normal)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        return shareButton
    }()
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.2
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        setUpElements()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setConstraint()
    }
    
    @objc private func goBack() {
        dismiss(animated: true)
    }
    
    @objc private func share() {
        guard let image = image.image else { return }
        
        let activityController = UIActivityViewController(
            activityItems: [image, String(describing: image)],
            applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    private func addViews() {
        view.addSubviews(scrollView, backButton, shareButton)
        scrollView.addSubview(image)
    }
    
    private func setUpElements() {
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        scrollView.delegate = self
    }
    
    public func configureImage(imageName: String) {
        image.image = UIImage(named: "\(imageName)")
        rescaleAndCenterImageInScrollView(image.image ?? UIImage())
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            // pictureImage
            image.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: 0),
            image.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: 0),
            image.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: 0),
            image.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 0),
            
            // scrollView
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(
                equalTo: view.topAnchor),
            
            // backButton
            backButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 9),
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 9),
            
            // shareButton
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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
        scrollView.setZoomScale(scale, animated: true)
        
        scrollView.layoutIfNeeded()
        let newContentsSize = scrollView.contentSize
        let x = (newContentsSize.width - visibleRectSize.width) / 2
        let y = (newContentsSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: true)
    }
}

extension DetailImagesListViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return image
    }
}
