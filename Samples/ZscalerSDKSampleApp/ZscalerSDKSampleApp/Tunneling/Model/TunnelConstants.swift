import Foundation
import UIKit

public struct TunnelConstants {

    static func appKey() -> String {
        readValue(forKey: "appKey")
    }

    static func deviceUUID() -> String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    static func accessToken() -> String {
        readValue(forKey: "accessToken")
    }
    
    private static func readValue(forKey key: String) -> String {
        guard let path = Bundle.main.path(forResource: "secrets", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let dictionary = json as? [String: String] else {
            return ""
        }
        return dictionary[key] ?? ""
    }
}
