import Firebase
import FirebaseCrashlytics

class CrashlyticsService {
    public static let shared = CrashlyticsService()

    private init() {}

    public func initCrashlytics() {
        FirebaseApp.configure()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    }
}
