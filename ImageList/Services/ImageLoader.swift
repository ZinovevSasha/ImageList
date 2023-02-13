import Foundation

protocol ImageLoaderProtocol {
    func loadData()
}

final class ImageLoader: ImageLoaderProtocol {
    weak var delegate: ImageLoaderDelegate?
    
    init(delegate: ImageLoaderDelegate) {
        self.delegate = delegate
    }
    
    private var images: [ImageCell] = []
    
    func loadData() {
        images = Array(0..<20).map { ImageCell(image: "\($0)", date: Date(), isLiked: "\($0)") }
       
            delegate?.imageLoader(self, didLoadImages: images)
    }
}
