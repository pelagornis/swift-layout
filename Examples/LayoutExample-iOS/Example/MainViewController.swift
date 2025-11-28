import UIKit
import Layout

final class MainViewController: UITabBarController {
    let homeViewController = HomeViewController()
    let advancedViewController = AdvancedFeaturesViewController()
    let geometryViewController = GeometryReaderDemoViewController()
    let settingViewController = SettingViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeNav = UINavigationController(rootViewController: homeViewController)
        let advancedNav = UINavigationController(rootViewController: advancedViewController)
        let geometryNav = UINavigationController(rootViewController: geometryViewController)
        let settingNav = UINavigationController(rootViewController: settingViewController)
        
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        advancedNav.tabBarItem = UITabBarItem(title: "Advanced", image: UIImage(systemName: "sparkles"), tag: 1)
        geometryNav.tabBarItem = UITabBarItem(title: "Geometry", image: UIImage(systemName: "square.resize"), tag: 2)
        settingNav.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gear"), tag: 3)

        setViewControllers([homeNav, advancedNav, geometryNav, settingNav], animated: true)
    }
}
