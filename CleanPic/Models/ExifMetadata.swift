import Foundation

struct ExifMetadata: Identifiable {
    let id = UUID()
    let category: MetadataCategory
    let key: String
    let value: String
    let displayName: String
}
