import UIKit
import ImageIO
import UniformTypeIdentifiers

class ExifPurgeService {
    func removeMetadata(from image: UIImage) -> Data? {
        guard let cgImage = image.cgImage else {
            return nil
        }

        let data = NSMutableData()

        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        CGImageDestinationAddImage(destination, cgImage, nil)

        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return data as Data
    }
}
