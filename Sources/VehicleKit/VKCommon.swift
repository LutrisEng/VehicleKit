import Foundation

class VKCommon {
    static func encodeURIComponent(_ component: String) -> String? {
        let characterSet = NSMutableCharacterSet.urlQueryAllowed
        return component.addingPercentEncoding(withAllowedCharacters: characterSet)
    }

    static func encodeURIQuery(parameters: [String: String]) -> String? {
        let components = parameters.compactMap { (key, value) -> String? in
            if let key = encodeURIComponent(key), let value = encodeURIComponent(value) {
                return "\(key)=\(value)"
            } else {
                return nil
            }
        }
        return components.joined(separator: "&")
    }
}
