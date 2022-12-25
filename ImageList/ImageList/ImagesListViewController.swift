import UIKit

final class ImagesListViewController: UIViewController {
    private var photosName: [ImageListCell] = []
    private var imageLoader: ImageLoaderProtocol?
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
        createTableView()
        view.backgroundColor = .ypBlack
        tableView.allowsSelection = false
        tableView.contentInset.top = 16
        tableView.contentOffset.y = -16
        imageLoader = ImageLoader(delegate: self)
        imageLoader?.loadData()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func createTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.identifier,
            for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        cell.configure(model: photosName[indexPath.row])
        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: "\(indexPath.row)") else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let scale = imageViewWidth / imageWidth
        let cellHeight = (imageHeight * scale) + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: ImageListDelegate {
    func didLoadQuestions(questions: [ImageListCell]) {
        photosName = questions
    }
}
