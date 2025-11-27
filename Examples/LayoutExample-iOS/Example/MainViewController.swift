import UIKit
import Layout

final class MainViewController: UITabBarController {
    let homeViewController = HomeViewController()
    let settingViewController = SettingViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        settingViewController.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gear"), tag: 1)

        setViewControllers([homeViewController, settingViewController], animated: true)
    }
}
