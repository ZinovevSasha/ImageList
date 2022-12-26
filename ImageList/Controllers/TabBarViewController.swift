import UIKit

final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = ImagesListViewController()
        let vc2 = ProfileViewController()
        
        let nav = UINavigationController(rootViewController: vc1)
        nav.tabBarItem = UITabBarItem(
            title: "",
            image: .tabBarLeft,
            tag: 1)
        vc2.tabBarItem = UITabBarItem(
            title: "",
            image: .tabBarRight,
            tag: 2)

        setViewControllers([nav, vc2], animated: false)
        
        let appearance1 = UITabBarAppearance()
        appearance1.configureWithOpaqueBackground()
        appearance1.backgroundColor = .ypBlack
        tabBar.standardAppearance = appearance1
        tabBar.tintColor = .white
    }
}
