import Foundation

protocol DefaultsLike {
    func array(forKey defaultName: String) -> [Any]?
    func string(forKey defaultName: String) -> String?
    func dictionary(forKey defaultName: String) -> [String : Any]?
    func data(forKey defaultName: String) -> Data?
    func removeObject(forKey defaultName: String)
    func setValue(_ value: Any?, forKey: String)
    func set(_ value: Any?, forKey: String)
    func synchronize() -> Bool
    func keys() -> [String]

    func setDictionarySafe(_ dict: [String: Any], forKey key: String)
    func dictionarySafe(forKey key: String) -> [String: Any]?
}

extension UserDefaults: DefaultsLike {
    func setDictionarySafe(_ dict: [String: Any], forKey key: String) {
        guard JSONSerialization.isValidJSONObject(dict),
              let json = try? JSONSerialization.data(withJSONObject: dict) else {
            print("[Statsig]: Failed to save to cache")
            return
        }

        self.set(json, forKey: key)
    }

    func dictionarySafe(forKey key: String) -> [String: Any]? {
        do {
            guard let data = self.data(forKey: key) else {
                return nil
            }

            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return nil
            }

            return dict
        } catch {
            return nil
        }
    }

    func keys() -> [String] {
        return self.dictionaryRepresentation().keys.sorted()
    }
}

private let FileBasedUserDefaultsQueue = "com.Statsig.FileBasedUserDefaults"

class FileBasedUserDefaults: DefaultsLike {
    private let cacheUrl = FileManager
        .default.urls(for: .cachesDirectory, in: .userDomainMask)
        .first?.appendingPathComponent("statsig-cache-data")

    private var dict: AtomicDictionary<Any?> = AtomicDictionary(label: FileBasedUserDefaultsQueue)

    init() {
        readFromDisk()
    }

    func array(forKey defaultName: String) -> [Any]? {
        getValue(forKey: defaultName) as? [Any]
    }

    func string(forKey defaultName: String) -> String? {
        getValue(forKey: defaultName) as? String
    }

    func dictionary(forKey defaultName: String) -> [String : Any]? {
        getValue(forKey: defaultName) as? [String : Any]
    }

    func data(forKey defaultName: String) -> Data? {
        getValue(forKey: defaultName) as? Data
    }

    func removeObject(forKey defaultName: String) {
        dict[defaultName] = nil
        _ = writeToDisk()
    }

    func setValue(_ value: Any?, forKey: String) {
        set(value, forKey: forKey)
    }

    func set(_ value: Any?, forKey: String) {
        dict[forKey] = value
        _ = writeToDisk()
    }

    func synchronize() -> Bool {
        return writeToDisk()
    }

    func keys() -> [String] {
        return dict.keys()
    }

    func setDictionarySafe(_ dict: [String: Any], forKey key: String) {
        // File storage doesn't actaully need this Safe func call, just call the standard .set
        set(dict, forKey: key)
    }

    func dictionarySafe(forKey key: String) -> [String: Any]? {
        // File storage doesn't actaully need this Safe func call, just call the standard .dictionary
        return dictionary(forKey: key)
    }

    private func getValue(forKey key: String) -> Any? {
        return dict[key] as? Any
    }

    private func writeToDisk() -> Bool {
        guard let url = cacheUrl else {
            return false
        }

        do {
            try dict.toData()?.write(to: url)
        } catch {
            return false
        }

        return true
    }

    private func readFromDisk() {
        guard let url = cacheUrl else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            dict = AtomicDictionary.fromData(data, label: FileBasedUserDefaultsQueue)
        } catch {
            return
        }
    }
}

class StatsigUserDefaults {
    static var defaults: DefaultsLike = UserDefaults.standard
}
