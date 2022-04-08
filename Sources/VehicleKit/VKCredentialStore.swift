import Foundation

public protocol VKCredentialStore {
    func read(key: String) -> Data?
    func write(key: String, value: Data)
}

extension NSUbiquitousKeyValueStore: VKCredentialStore {
    public func read(key: String) -> Data? {
        return data(forKey: key)
    }

    public func write(key: String, value: Data) {
        set(value, forKey: key)
    }
}
