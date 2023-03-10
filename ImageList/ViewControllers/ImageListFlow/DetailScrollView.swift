//
//  DetailScrollView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 10.03.2023.
//

import UIKit

final class DetailScrollView: UIScrollView {
    private var imageView: UIImageView?
    
    lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(
            target: self, action: #selector(doubleTapAction(_:))
        )
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        delegate = self
        minimumZoomScale = 0.1
        maximumZoomScale = 0.7
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    @objc func doubleTapAction(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: recognizer.view)
        let zoomRect = zoomRect(point: point)
        self.zoom(to: zoomRect, animated: true)
    }
    
    private func zoomRect(point: CGPoint) -> CGRect {
        let imageViewSize = imageView?.frame.size ?? .zero
        let scale = maximumZoomScale
        let zoomRect = CGRect(
            x: point.x - imageViewSize.width / (2 * scale),
            y: point.y - imageViewSize.height / (2 * scale),
            width: imageViewSize.width / scale,
            height: imageViewSize.height / scale
        )
        return zoomRect
    }
}

extension DetailScrollView {
    public func setImageView(_ imageView: UIImageView) {
        self.imageView = imageView
        
        addSubview(imageView)
        self.imageView?.addGestureRecognizer(zoomingTap)
        self.imageView?.isUserInteractionEnabled = true
    }
    
    public func centerImageAfterZooming() {
        let scrollViewSize = self.bounds.size
        let imageSize = imageView?.frame ?? .zero
        let horizontalPadding = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalPadding = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0
        self.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        )
    }
    
    public func rescaleImage() {
        let minZoomScale = self.minimumZoomScale
        let maxZoomScale = self.maximumZoomScale
        let visibleRectSize = self.bounds.size
        let imageSize = imageView?.image?.size ?? .zero
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let theoreticalScale = max(hScale, vScale)
        let scale = min(maxZoomScale, max(minZoomScale, theoreticalScale))
        
        self.setZoomScale(scale, animated: false)
    }
    
    public func centerImage() {
        let newContentsSize = self.contentSize
        let visibleRectSize = self.bounds.size
        let x = (newContentsSize.width - visibleRectSize.width) / 2
        let y = (newContentsSize.height - visibleRectSize.height) / 2
        
        self.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate
extension DetailScrollView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
       centerImageAfterZooming()
    }
}
