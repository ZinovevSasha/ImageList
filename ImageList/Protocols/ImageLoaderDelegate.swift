protocol ImageLoaderDelegate: AnyObject {
    func didLoadImages(_: ImageLoaderProtocol, _ images: [ImageCell])
}
