import UIKit
import Layout

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Layout debugging in DEBUG builds
        #if DEBUG
        configureLayoutDebugging()
        #endif
        
        return true
    }
    
    // MARK: - Layout Debugging Configuration
    
    #if DEBUG
    private func configureLayoutDebugging() {
        // Enable all layout debugging features
        LayoutDebugger.shared.enableAll()
        
        // Or enable only specific features:
        // LayoutDebugger.shared.isEnabled = true
        // LayoutDebugger.shared.enableLayoutCalculation = true
        // LayoutDebugger.shared.enableViewHierarchy = true
        // LayoutDebugger.shared.enableFrameSettings = true
        // LayoutDebugger.shared.enableSpacerCalculation = true
        // LayoutDebugger.shared.enablePerformanceMonitoring = true
        
        print("🔧 [Layout] Debug mode enabled")
        print("📊 Available debug categories:")
        print("   - Layout Calculation: \(LayoutDebugger.shared.enableLayoutCalculation)")
        print("   - View Hierarchy: \(LayoutDebugger.shared.enableViewHierarchy)")
        print("   - Frame Settings: \(LayoutDebugger.shared.enableFrameSettings)")
        print("   - Spacer Calculation: \(LayoutDebugger.shared.enableSpacerCalculation)")
        print("   - Performance Monitoring: \(LayoutDebugger.shared.enablePerformanceMonitoring)")
    }
    #endif

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
