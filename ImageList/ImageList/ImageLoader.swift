import Foundation

protocol ImageListDelegate: AnyObject {
    func didLoadQuestions(questions: [ImageListCell])
}

protocol ImageLoaderProtocol {
    func loadData()
}

class ImageLoader: ImageLoaderProtocol {
    weak var delegate: ImageListDelegate?
    init(delegate: ImageListDelegate) {
        self.delegate = delegate
    }
    
    var data: [ImageListCell] = []
    
    func loadData() {
        data = Array(0..<20).map { ImageListCell(image: "\($0)", date: Date(), isLiked: "\($0)") }
        
        delegate?.didLoadQuestions(questions: data)
    }
}
