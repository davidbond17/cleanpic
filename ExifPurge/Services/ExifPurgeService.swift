import UIKit
import ImageIO
import UniformTypeIdentifiers

class ExifPurgeService {
    func removeMetadata(from image: UIImage) -> Data? {
        let fixedImage = normalizeImageOrientation(image)

        guard let cgImage = fixedImage.cgImage else {
            print("❌ Could not get CGImage")
            return nil
        }

        let data = NSMutableData()

        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            print("❌ Could not create image destination")
            return nil
        }

        let properties: [CFString: Any] = [
            kCGImagePropertyOrientation: 1
        ]

        CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            print("❌ Could not finalize image destination")
            return nil
        }

        print("✅ Successfully removed metadata with correct orientation")
        return data as Data
    }

    private func normalizeImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            print("📐 Image already correctly oriented")
            return image
        }

        print("📐 Fixing image orientation from: \(image.imageOrientation.rawValue)")

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let result = normalizedImage else {
            print("⚠️ Could not normalize orientation, returning original")
            return image
        }

        print("✅ Image orientation fixed")
        return result
    }
}
