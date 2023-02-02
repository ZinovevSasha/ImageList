//
//  ImageListPresenter.swift
//  ImageList
//
//  Created by Александр Зиновьев on 10.01.2023.
//

import UIKit

protocol ImageListProtocol: AnyObject {
    func presentDetailVC(image: ImageCell)
    func reloadData()
}

final class ImageListPresenter: NSObject {
    // Dependencies
    private weak var imageList: ImageListProtocol?
    private var imageLoader: ImageLoaderProtocol?
  
    private var images: [ImageCell] = []
    
    // Init
    init(imageList: ImageListProtocol?) {
        super.init()
        self.imageList = imageList
        imageLoader = ImageLoader(delegate: self)
        imageLoader?.loadData()
    }
    
    private func heightForCell(basedOn image: UIImage, tableView: UITableView) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let scale = imageViewWidth / imageWidth
        let cellHeight = (imageHeight * scale) + imageInsets.top + imageInsets.bottom + 60
        return cellHeight
    }
}

extension ImageListPresenter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = images[indexPath.row].image
        guard let image = UIImage(named: "\(imageName)") else {
            return 0
        }
        return heightForCell(basedOn: image, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let picture = images[indexPath.row]
        imageList?.presentDetailVC(image: picture)
    }
}

extension ImageListPresenter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.identifier,
            for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }

        cell.configure(model: images[indexPath.row])
        return cell
    }
}

extension ImageListPresenter: ImageLoaderDelegate {
    func didLoadImages(_: ImageLoaderProtocol, _ images: [ImageCell]) {
        self.images = images
        imageList?.reloadData()
    }
}
