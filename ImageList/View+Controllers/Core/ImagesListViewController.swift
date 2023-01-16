import UIKit

final class ImagesListViewController: UIViewController, ImageListProtocol {
    // Dependencies
    private var presenter: ImageListPresenter?
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(
            ImagesListCell.self,
            forCellReuseIdentifier: ImagesListCell.identifier)
        return tableView
    }()

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
        view.backgroundColor = .clear
        view.addSubview(tableView)
    }
    
    public func reloadData() {
        tableView.reloadData()
    }
    
    public func presentDetailVC(image: ImageCell) {
        let vcDetail = DetailImagesListViewController()
        vcDetail.modalPresentationStyle = .fullScreen
        vcDetail.configureImage(imageName: image.image)
        present(vcDetail, animated: true)
    }
}
