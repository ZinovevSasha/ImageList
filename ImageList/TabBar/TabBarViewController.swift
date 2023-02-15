import UIKit

final class TabBarController: UITabBarController {
    // MARK: - Dependency
    private let profileInfo: Profile?
    
    // MARK: - Init (Dependency injection)
    init(
        profileInfo: Profile?
    ) {
        self.profileInfo = profileInfo
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = ImagesListViewController()
        let vc2 = ProfileViewController(profileInfo: profileInfo)
        
        vc1.tabBarItem = UITabBarItem(
            title: "",
            image: .tabBarLeft,
            tag: 1)
        vc2.tabBarItem = UITabBarItem(
            title: "",
            image: .tabBarRight,
            tag: 2)

        setViewControllers([vc1, vc2], animated: false)
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .myBlack
        appearance.selectionIndicatorTintColor = .black
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.tintColor = .white
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard
            let tabViewControllers = tabBarController.viewControllers,
            let targetIndex = tabViewControllers.firstIndex(of: viewController),
            let targetView = tabViewControllers[targetIndex].view,
            let currentViewController = selectedViewController,
            let currentIndex = tabViewControllers.firstIndex(of: currentViewController)
            else { return false }

        if currentIndex != targetIndex {
            animateToView(targetView, at: targetIndex, from: currentViewController.view, at: currentIndex)
        }

        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let barItemView = item.value(forKey: "view") as? UIView else { return }
        barItemView.animate(.init(scaleX: 0.5, y: 0.5))
        barItemView.animate(.identity)
    }
}

private extension TabBarController {
    func animateToView(_ toView: UIView, at toIndex: Int, from fromView: UIView, at fromIndex: Int) {
        // Position toView off screen (to the left/right of fromView)
        let screenWidth = UIScreen.main.bounds.size.width
        let offset = toIndex > fromIndex ? screenWidth : -screenWidth

        toView.frame.origin = CGPoint(
            x: toView.frame.origin.x + offset,
            y: toView.frame.origin.y
        )

        fromView.superview?.addSubview(toView)

        // Disable interaction during animation
        view.isUserInteractionEnabled = false

        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut,
            animations: {
                // Slide the views by -offset
                fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y)
                toView.center = CGPoint(x: toView.center.x - offset, y: toView.center.y)
            },
            completion: { _ in
                // Remove the old view from the tabbar view.
                fromView.removeFromSuperview()
                self.selectedIndex = toIndex
                self.view.isUserInteractionEnabled = true
            }
        )
    }
}
