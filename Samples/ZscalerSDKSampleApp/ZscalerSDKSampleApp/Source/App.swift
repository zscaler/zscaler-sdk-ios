
import SwiftUI
import OSLog

let logger = Logger()

// TODO: load and save configuration to disk
// TODO: default configuration
// TODO: simplify tunnelviewmodel - can it 

@main
struct TestApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
