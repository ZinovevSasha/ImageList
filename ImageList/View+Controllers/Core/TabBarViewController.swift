import UIKit

final class TabBarViewController: UITabBarController {
    // MARK: - Dependency
    private let profileInfo: Profile?
    
    // MARK: - Init (Dependency injection)
    init(
        profileInfo: Profile?
    ) {
        self.profileInfo = profileInfo
        super.init(nibName: nil, bundle: nil)
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
