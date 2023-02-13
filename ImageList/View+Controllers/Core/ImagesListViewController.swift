import UIKit

final class ImagesListViewController: UIViewController, ImageListProtocol {
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(
            ImagesListCell.self,
            forCellReuseIdentifier: ImagesListCell.identifier)
        return tableView
    }()
    
    // Dependency
    private var presenter: ImageListPresenter?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ImageListPresenter(imageList: self)
        createTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    private func createTableView() {
        tableView.dataSource = presenter
        tableView.delegate = presenter
        tableView.contentInset.top = 16
        tableView.contentOffset.y = -16
        view.backgroundColor = .myBlack
        view.addSubview(tableView)
    }
    
    public func reloadData() {
        tableView.reloadData()
    }
    
    public func presentDetailVC(image: ImageCell) {
        let vcDetail = DetailImagesListViewController()
        vcDetail.configure(image: image.image)
        vcDetail.modalPresentationStyle = .fullScreen
        present(vcDetail, animated: true)
    }
}
