
import Foundation
import UIKit

struct CloudConfig {
    let preloginUrl: String
    let zeroTrustUrl: String
    
    static func config(for environment: AppSecrets.Environment) -> CloudConfig {
        switch environment {
        case .dev2:
            return CloudConfig(
                preloginUrl: "https://prelogin.dev2.zsdk.automation.dev.zpath.net/",
                zeroTrustUrl: "https://zerotrust.dev2.zsdk.automation.dev.zpath.net/"
            )
        case .qa2:
            return CloudConfig(
                preloginUrl: "https://prelogin.us.zsdk.automation.dev.zpath.net/",
                zeroTrustUrl: "https://zerotrust.us.zsdk.automation.dev.zpath.net/"
            )
        case .staging:
            return CloudConfig(
                preloginUrl: "https://prelogin.staging.zsdk.automation.dev.zpath.net/",
                zeroTrustUrl: "https://zerotrust.staging.zsdk.automation.dev.zpath.net/"
            )
        case .prod:
            return CloudConfig(
                preloginUrl: "https://prelogin.prod.zsdk.automation.dev.zpath.net/",
                zeroTrustUrl: "https://zerotrust.prod.zsdk.automation.dev.zpath.net/"
            )
        }
    }
}

struct AppSecrets: Codable {
    let appKeys: AppKeyConstants
    let accessTokens: AccessTokenConstants
    let authServerCreds: AuthServerCredentials
    
    enum CodingKeys: String, CodingKey {
        case appKeys
        case accessTokens
        case authServerCreds
    }
    
    struct AppKeyConstants: Codable {
        let valid: String
        let notJson: String
    }

    struct AccessTokenConstants: Codable {
        let valid: String
        let badJson: String
    }
    
    struct AuthServerCredentials: Codable {
        let clientId: String
        let clientSecret: String

        enum CodingKeys: String, CodingKey {
            case clientId = "client_id"
            case clientSecret = "clientsecret"
        }
    }
    
    enum Environment: String {
        case dev2 = "secrets_dev2"
        case qa2 = "secrets_qa2"
        case staging = "secrets_staging"
        case prod = "secrets_prod"
        
        // Change this to the desired environment: dev2, qa2, staging, or prod
        static let current: Environment = .qa2
    }
}

extension AppSecrets {
    static func readFrom(environment: Environment, bundle: Bundle) -> AppSecrets? {
        guard let url = bundle.url(forResource: environment.rawValue, withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(AppSecrets.self, from: data)
        } catch {
            return nil
        }
    }
}

@MainActor public class AppConstants {
    
    static let shared = AppConstants()
    
    let secrets: AppSecrets?
    let environment: AppSecrets.Environment
    let cloudConfig: CloudConfig
    private var uuid: UUID?
    
    // Private initializer to enforce singleton pattern
    private init() {
        self.environment = AppSecrets.Environment.current
        self.secrets = AppSecrets.readFrom(environment: environment, bundle: .main)
        self.cloudConfig = CloudConfig.config(for: environment)
    }
    
    func validUrl() -> String? {
        return cloudConfig.preloginUrl
    }
    
    func appKey() -> String? {
        return secrets?.appKeys.valid
    }

    func accessToken() -> String? {
        return secrets?.accessTokens.valid
    }
    
    func deviceUUID() -> String {
        // If UUID already exists, return it
        if let uuid = self.uuid {
            return uuid.uuidString
        }
        // Otherwise, create, store, and return a new one
        let newUUID = UIDevice.current.identifierForVendor ?? UUID()
        self.uuid = newUUID
        return newUUID.uuidString
    }
}
