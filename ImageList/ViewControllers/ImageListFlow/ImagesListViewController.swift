import UIKit

protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListPresenterProtocol! { get }
    func stopSpinner()
    func startSpinner()
    func updateTableViewAnimated(at indexPath: [IndexPath])
    func showProgress()
    func hideProgress()
    func cellToggle(like: Bool, for cell: ImageListTableViewCell)
    func showAlert()    
}

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
    
    var presenter: ImageListPresenterProtocol!
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ImageListPresenter(
            view: self,
            imageListService: ImageListService(
                requests: UnsplashRequest(
                    configuration: UnsplashAuthConfiguration.standard,
                    authTokenStorage: OAuth2TokenStorage(),
                    requestBuilder: RequestBuilder()
                )
            )
        )
        
        createTableView()
        presenter.viewDidLoad()
    }
    
    private func createTableView() {
        tableView.frame = view.bounds
        spinner.center = view.center
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubviews(tableView, spinner)
    }
    
    private func presentDetailImagesListViewController(with indexPath: IndexPath) {
        let vcDetail = DetailImagesListViewController()
        vcDetail.modalPresentationStyle = .fullScreen
        let stringURL = presenter.getImageURL(at: indexPath.row)
        vcDetail.configure(with: stringURL)
        self.present(vcDetail, animated: true)
    }
}

extension ImagesListViewController: ImageListViewControllerProtocol {
    func startSpinner() {
        spinner.startAnimating()
    }
    
    func updateTableViewAnimated(at indexPath: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPath, with: .automatic)
        }
    }
    
    func stopSpinner() {
        spinner.stopAnimating()
    }
    
    func showProgress() {
        UIBlockingProgressHUD.show()
    }
    
    func hideProgress() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func cellToggle(like: Bool, for cell: ImageListTableViewCell) {
        cell.setLike(like)
    }
    
    func showAlert() {
        showAlert(
            title: "Что то пошло не так(",
            message: "Попробуйте ещё раз!",
            actions: [ Action(title: "Ок", style: .default, handler: nil) ]
        )
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = presenter.heightForCell(
            at: indexPath.row, widthOfScreen: tableView.frame.width
        )
        return size
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentDetailImagesListViewController(with: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.fetchNextPhotosIfNeeded(index: indexPath.row)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getTotalNumberOfImages()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImageListTableViewCell.reusableIdentifier,
            for: indexPath) as? ImageListTableViewCell else {
            return UITableViewCell()
        }
        let photo = presenter.getPhoto(at: indexPath.row)
        cell.delegate = self
        cell.configure(with: photo)
        return cell
    }
}

extension ImagesListViewController: ImageListTableViewCellDelegate {
    func imageListCellDidTapLikeButton(_ cell: ImageListTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.setLikeForPhotoAtIndex(index: indexPath.row, for: cell)
    }
}
