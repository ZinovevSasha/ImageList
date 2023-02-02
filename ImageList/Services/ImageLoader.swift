import Foundation

final class ImageLoader: ImageLoaderProtocol {
    weak var delegate: ImageLoaderDelegate?
    
    init(delegate: ImageLoaderDelegate) {
        self.delegate = delegate
    }
    
    private var data: [ImageCell] = []
    
    func loadData() {
        data = Array(0..<20).map { ImageCell(image: "\($0)", date: Date(), isLiked: "\($0)") }
       
            delegate?.didLoadImages(self, data)
    }
}
