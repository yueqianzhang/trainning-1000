import Foundation

@propertyWrapper
struct UserDefault<T: Codable> {
    let container: UserDefaults
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            if let data = container.object(forKey: key) as? Data,
               let value = try? JSONDecoder().decode(T.self, from: data) {
                return value
            }
            return defaultValue
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            container.set(data, forKey: key)
        }
    }
    
    var projectedValue: Self { self }

    init(container: UserDefaults = .standard, _ key: String, opt: T) {
        self.container = container
        self.key = key
        self.defaultValue = opt
    }
    
    var isUnset: Bool { container.object(forKey: key) == nil }
    func unset() { container.removeObject(forKey: key) }
}

// MARK: - DEMO

extension UserDefaults {
    struct AppSettings {
        @UserDefault(scope + "darkMode", opt: false)
        static var darkMode: Bool
        
        private static let scope = "appSettings."
    }
}

UserDefaults.AppSettings.darkMode = true
print("key == \(UserDefaults.AppSettings.$darkMode.key), val == \(UserDefaults.AppSettings.darkMode)")
print("isUnset == \(UserDefaults.AppSettings.$darkMode.isUnset)")

print("--------------------------------------------------------")

UserDefaults.AppSettings.$darkMode.unset()
print("key == \(UserDefaults.AppSettings.$darkMode.key), val == \(UserDefaults.AppSettings.darkMode)")
print("isUnset == \(UserDefaults.AppSettings.$darkMode.isUnset)")
