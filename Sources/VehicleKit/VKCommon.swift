import Foundation

class VKCommon {
    static func encodeURIComponent(_ component: String) -> String? {
        let characterSet = NSMutableCharacterSet.urlQueryAllowed
        return component.addingPercentEncoding(withAllowedCharacters: characterSet)
    }

    static func encodeURIQuery(parameters: [String: String]) -> String? {
        let components = parameters.compactMap { (k, v) -> String? in
            if let k = encodeURIComponent(k), let v = encodeURIComponent(v) {
                return "\(k)=\(v)"
            } else {
                return nil
            }
        }
        return components.joined(separator: "&")
    }
}
