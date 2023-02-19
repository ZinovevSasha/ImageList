import UIKit

protocol ImageListPresenterProtocol {}

final class ImagesListViewController: UIViewController {
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(
            ImageTableViewCell.self,
            forCellReuseIdentifier: ImageTableViewCell.reusableIdentifier)
        return tableView
    }()
    
    private var activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    private var imageListServiceObserver: NSObjectProtocol?
    
    // Dependency
    private var imageListService: ImageListServiceProtocol
    
    // MARK: - Init
    init(
        imageListService: ImageListServiceProtocol
    ) {
        self.imageListService = imageListService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTableView()
    }
    
    private func createTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        activityIndicatorView.center = view.center
        tableView.isHidden = true
        activityIndicatorView.startAnimating()
        view.backgroundColor = .myBlack
        view.addSubview(tableView)
        subscribeToNotification()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.visibleCells.forEach { $0.setNeedsLayout() }
    }
    
    private func heightForCell(_ imageSize: CGSize, tableView: UITableView) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        let scale = imageViewWidth / imageWidth
        let cellHeight = (imageHeight * scale) + imageInsets.top + imageInsets.bottom + 60
        return cellHeight
    }
    
    private func presentDetailVC() {
        let vcDetail = DetailImagesListViewController()
        vcDetail.configure(image: "FF")
        vcDetail.modalPresentationStyle = .fullScreen
        present(vcDetail, animated: true)
    }
    
    private func subscribeToNotification() {
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImageListService.DidChangeNotification,
                object: nil,
                queue: .main) { [weak self] _ in
                    self?.activityIndicatorView.startAnimating()
                    self?.tableView.isHidden = false
                    self?.tableView.reloadData()
            }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageSize = imageListService.photos[indexPath.row].size
        return heightForCell(imageSize, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentDetailVC()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imageListService.photos.count {
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
            withIdentifier: ImageTableViewCell.reusableIdentifier,
            for: indexPath) as? ImageTableViewCell else {
            return UITableViewCell()
        }

        cell.configureCell(with: imageListService.photos[indexPath.row])
        return cell
    }
}
