protocol ImageLoaderDelegate: AnyObject {
    func imageLoader(_ imageLoader: ImageLoaderProtocol, didLoadImages: [ImageCell])
}
