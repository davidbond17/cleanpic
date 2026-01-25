import UIKit
import PhotosUI

struct BatchPhotoItem: Identifiable {
    let id = UUID()
    let image: UIImage
    let imageData: Data
    let asset: PHAsset?
    var metadata: [ExifMetadata] = []

    var metadataCount: Int {
        metadata.count
    }
}
