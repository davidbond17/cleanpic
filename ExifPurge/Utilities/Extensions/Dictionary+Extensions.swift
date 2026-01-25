import Foundation

extension Dictionary where Key == String, Value == Any {
    func flatten(prefix: String = "") -> [String: Any] {
        var result: [String: Any] = [:]

        for (key, value) in self {
            let newKey = prefix.isEmpty ? key : "\(prefix).\(key)"

            if let dict = value as? [String: Any] {
                let flattened = dict.flatten(prefix: newKey)
                result.merge(flattened) { _, new in new }
            } else {
                result[newKey] = value
            }
        }

        return result
    }
}
