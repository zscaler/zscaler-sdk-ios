import Foundation
import UIKit

public struct TunnelConstants {

    static func appKey() -> String {
        guard let appKeys = readSecrets()["appKeys"] as? [String:String] else {
            return ""
        }
        return appKeys["valid"] ?? ""
    }

    static func deviceUUID() -> String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    static func accessToken() -> String {
        guard let appKeys = readSecrets()["accessTokens"] as? [String:String] else {
            return ""
        }
        return appKeys["valid"] ?? ""
    }
    
    private static func readSecrets() -> [String:Any] {
        guard let url = Bundle.main.url(forResource: "secrets", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let dictionary = json as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}
