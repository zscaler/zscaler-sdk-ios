import UIKit
import OSLog

let logger = Logger()

@available(iOS 13.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if isGoogleServicePlistValid() {
            CrashlyticsService.shared.initCrashlytics()
        }
        return true
    }

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

    func isGoogleServicePlistValid() -> Bool {
        struct GooleServiceInfoPlist: Codable {
            let API_KEY: String
        }

        guard let fileUrl = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") else {
            return false
        }

        do {
            let data = try Data(contentsOf: fileUrl)
            let plist = try PropertyListDecoder().decode(GooleServiceInfoPlist.self, from: data)
            return !plist.API_KEY.isEmpty
        } catch {
            return false
        }
    }
}
