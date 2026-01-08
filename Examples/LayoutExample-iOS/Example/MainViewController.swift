import UIKit
import Layout

final class MainViewController: UITabBarController {
    let homeViewController = HomeViewController()
    let animationViewController = AnimationDemoViewController()
    let advancedViewController = AdvancedFeaturesViewController()
    let geometryViewController = GeometryReaderDemoViewController()
    let settingViewController = SettingViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeNav = UINavigationController(rootViewController: homeViewController)
        let animationNav = UINavigationController(rootViewController: animationViewController)
        let advancedNav = UINavigationController(rootViewController: advancedViewController)
        let geometryNav = UINavigationController(rootViewController: geometryViewController)
        let settingNav = UINavigationController(rootViewController: settingViewController)
        
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        animationNav.tabBarItem = UITabBarItem(title: "Animation", image: UIImage(systemName: "wand.and.stars"), tag: 1)
        advancedNav.tabBarItem = UITabBarItem(title: "Advanced", image: UIImage(systemName: "sparkles"), tag: 2)
        geometryNav.tabBarItem = UITabBarItem(title: "Geometry", image: UIImage(systemName: "square.resize"), tag: 3)
        settingNav.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gearshape"), tag: 4)

        setViewControllers([homeNav, animationNav, advancedNav, geometryNav, settingNav], animated: true)
    }
}
