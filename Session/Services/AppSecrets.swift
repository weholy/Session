import Foundation

enum AppSecrets {
    static var groqKey: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "GroqAPIKey") as? String,
              !value.isEmpty,
              !value.hasPrefix("$(") else {
            return nil
        }
        return value
    }

    static var hasGroqKey: Bool { groqKey != nil }
}
