import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .myBlack
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
        tableView.contentOffset.y = 16
        tableView.showsVerticalScrollIndicator = false
        tableView.register(
            ImageListTableViewCell.self,
            forCellReuseIdentifier: ImageListTableViewCell.reusableIdentifier)
        return tableView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var imageListServiceObserver: NSObjectProtocol?
    
    // Dependency
    private var imageListService: ImageListServiceProtocol
    
    // MARK: - Init (Dependency injection)
    init(
        imageListService: ImageListServiceProtocol
    ) {
        self.imageListService = imageListService
        super.init(nibName: nil, bundle: nil)
        
        imageListService.fetchPhotosNextPage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cache = ImageCache.default
        cache.clearDiskCache()
        cache.clearMemoryCache()
        
        createTableView()
        spinner.startAnimating()
    }
    
    private func createTableView() {
        tableView.frame = view.bounds
        spinner.center = view.center
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubviews(tableView, spinner)
        subscribeToNotification()
    }
    
    private func heightForCell(_ imageSize: CGSize, tableView: UITableView) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        let scale = imageViewWidth / imageWidth
        let cellHeight = (imageHeight * scale) + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    private func presentDetailImagesListViewController(with indexPath: IndexPath) {
        let vcDetail = DetailImagesListViewController()
        vcDetail.modalPresentationStyle = .fullScreen
        let stringURL = imageListService.photos[indexPath.row].full
        vcDetail.configure(with: stringURL)
        self.present(vcDetail, animated: true)
    }
    
    private func subscribeToNotification() {
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .current) { [weak self] notification in
                guard let self = self,
                    let numberOfPictures = notification
                    .userInfo?[UserInfo.numberOfPictures.rawValue] as? Int
                else {
                    return
            }
            self.spinner.stopAnimating()
            self.updateTableViewAnimated(with: numberOfPictures)
        }
    }
    
    private func updateTableViewAnimated(with numberOfPicturesReceived: Int) {
        let oldCount = imageListService.photos.count - numberOfPicturesReceived
        let newCount = imageListService.photos.count
        let indexPath = (oldCount..<newCount).map { IndexPath(row: $0, section: .zero) }
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPath, with: .automatic)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageSize = imageListService.photos[indexPath.row].size
        return heightForCell(imageSize, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentDetailImagesListViewController(with: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 2 == imageListService.photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImageListTableViewCell.reusableIdentifier,
            for: indexPath) as? ImageListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        cell.configure(with: imageListService.photos[indexPath.row])
        return cell
    }
}

extension ImagesListViewController: ImageListTableViewCellDelegate {
    func imageListCellDidTapLikeButton(_ cell: ImageListTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = imageListService.photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(
            photoId: photo.id,
            isLiked: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                let likeNoLike = self.imageListService.photos[indexPath.row].isLiked
                cell.setLike(likeNoLike)
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showAlert(
                    title: "Что то пошло не так(",
                    message: "Попробуйте ещё раз!",
                    actions: [ Action(title: "Ок", style: .default, handler: nil) ]
                )
            }
        }
    }
}
