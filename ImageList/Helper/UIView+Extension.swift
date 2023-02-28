import UIKit

extension UIView {
    func addGradient (
        with layer: CAGradientLayer,
        colorSet: [UIColor],
        locations: [Double],
        startEndPoints: (CGPoint, CGPoint)? = nil,
        insertAt: UInt32
    ) {
        layer.frame.origin = .zero
        let layerColorSet = colorSet.map { $0.cgColor }
        let layerLocations = locations.map { $0 as NSNumber }
        
        layer.colors = layerColorSet
        layer.locations = layerLocations
        
        if let startEndPoints = startEndPoints {
            layer.startPoint = startEndPoints.0
            layer.endPoint = startEndPoints.1
        }
        
        // insert layer below all other subviews
        self.layer.insertSublayer(layer, at: insertAt)
    }
    
    func addSubviews(_ view: UIView...) {
        view.forEach { addSubview($0) }
    }
    
    func animate(_ transform: CGAffineTransform) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 3,
            options: [.curveEaseInOut]) {
                self.transform = transform
        }
    }
    
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        
        set (cornerRadius) {
            layer.masksToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }
}
