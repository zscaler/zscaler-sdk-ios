
import Foundation
import UIKit

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
        case qa2 = "secrets_qa2"
        
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
    
    let secrets: AppSecrets? = AppSecrets.readFrom(environment: .qa2, bundle: .main)
    private var uuid: UUID?
    
    // Private initializer to enforce singleton pattern
    private init() {}
    
    func validUrl() -> String? {
        return "https://prelogin.us.zsdk.automation.dev.zpath.net/anything?zsdk-prelogin"
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
