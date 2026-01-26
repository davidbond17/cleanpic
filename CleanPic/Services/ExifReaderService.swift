import UIKit
import ImageIO
import UniformTypeIdentifiers

class ExifReaderService {
    func readMetadata(from imageData: Data) -> [String: Any]? {
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }

        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return nil
        }

        return properties
    }

    func parseMetadata(_ rawProperties: [String: Any]) -> [ExifMetadata] {
        var metadata: [ExifMetadata] = []

        if let exifDict = rawProperties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            metadata.append(contentsOf: parseExifData(exifDict))
        }

        if let gpsDict = rawProperties[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            metadata.append(contentsOf: parseGPSData(gpsDict))
        }

        if let tiffDict = rawProperties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
            metadata.append(contentsOf: parseTIFFData(tiffDict))
        }

        if let iptcDict = rawProperties[kCGImagePropertyIPTCDictionary as String] as? [String: Any] {
            metadata.append(contentsOf: parseIPTCData(iptcDict))
        }

        metadata.append(contentsOf: parseBasicProperties(rawProperties))

        return metadata
    }

    private func parseGPSData(_ gpsDict: [String: Any]) -> [ExifMetadata] {
        var metadata: [ExifMetadata] = []

        let gpsKeys: [(key: String, display: String)] = [
            (kCGImagePropertyGPSLatitude as String, "Latitude"),
            (kCGImagePropertyGPSLongitude as String, "Longitude"),
            (kCGImagePropertyGPSAltitude as String, "Altitude"),
            (kCGImagePropertyGPSTimeStamp as String, "GPS Time"),
            (kCGImagePropertyGPSDateStamp as String, "GPS Date"),
            (kCGImagePropertyGPSProcessingMethod as String, "Processing Method")
        ]

        for (key, display) in gpsKeys {
            if let value = gpsDict[key] {
                metadata.append(ExifMetadata(
                    category: .location,
                    key: key,
                    value: "\(value)",
                    displayName: display
                ))
            }
        }

        if let latRef = gpsDict[kCGImagePropertyGPSLatitudeRef as String] {
            metadata.append(ExifMetadata(
                category: .location,
                key: kCGImagePropertyGPSLatitudeRef as String,
                value: "\(latRef)",
                displayName: "Latitude Ref"
            ))
        }

        if let lonRef = gpsDict[kCGImagePropertyGPSLongitudeRef as String] {
            metadata.append(ExifMetadata(
                category: .location,
                key: kCGImagePropertyGPSLongitudeRef as String,
                value: "\(lonRef)",
                displayName: "Longitude Ref"
            ))
        }

        return metadata
    }

    private func parseExifData(_ exifDict: [String: Any]) -> [ExifMetadata] {
        var metadata: [ExifMetadata] = []

        let cameraKeys: [(key: String, display: String)] = [
            (kCGImagePropertyExifFocalLength as String, "Focal Length"),
            (kCGImagePropertyExifFNumber as String, "Aperture (F-Number)"),
            (kCGImagePropertyExifISOSpeedRatings as String, "ISO Speed"),
            (kCGImagePropertyExifExposureTime as String, "Shutter Speed"),
            (kCGImagePropertyExifFlash as String, "Flash Mode"),
            (kCGImagePropertyExifLensModel as String, "Lens Model"),
            (kCGImagePropertyExifLensMake as String, "Lens Make"),
            (kCGImagePropertyExifExposureProgram as String, "Exposure Program"),
            (kCGImagePropertyExifWhiteBalance as String, "White Balance"),
            (kCGImagePropertyExifBrightnessValue as String, "Brightness")
        ]

        for (key, display) in cameraKeys {
            if let value = exifDict[key] {
                metadata.append(ExifMetadata(
                    category: .camera,
                    key: key,
                    value: "\(value)",
                    displayName: display
                ))
            }
        }

        let dateKeys: [(key: String, display: String)] = [
            (kCGImagePropertyExifDateTimeOriginal as String, "Original Date/Time"),
            (kCGImagePropertyExifDateTimeDigitized as String, "Digitized Date/Time")
        ]

        for (key, display) in dateKeys {
            if let value = exifDict[key] {
                metadata.append(ExifMetadata(
                    category: .dateTime,
                    key: key,
                    value: "\(value)",
                    displayName: display
                ))
            }
        }

        return metadata
    }

    private func parseTIFFData(_ tiffDict: [String: Any]) -> [ExifMetadata] {
        var metadata: [ExifMetadata] = []

        let deviceKeys: [(key: String, display: String)] = [
            (kCGImagePropertyTIFFMake as String, "Device Make"),
            (kCGImagePropertyTIFFModel as String, "Device Model"),
            (kCGImagePropertyTIFFSoftware as String, "Software")
        ]

        for (key, display) in deviceKeys {
            if let value = tiffDict[key] {
                let category: MetadataCategory = key == kCGImagePropertyTIFFSoftware as String ? .software : .device
                metadata.append(ExifMetadata(
                    category: category,
                    key: key,
                    value: "\(value)",
                    displayName: display
                ))
            }
        }

        if let orientation = tiffDict[kCGImagePropertyTIFFOrientation as String] {
            metadata.append(ExifMetadata(
                category: .other,
                key: kCGImagePropertyTIFFOrientation as String,
                value: "\(orientation)",
                displayName: "Orientation"
            ))
        }

        if let dateTime = tiffDict[kCGImagePropertyTIFFDateTime as String] {
            metadata.append(ExifMetadata(
                category: .dateTime,
                key: kCGImagePropertyTIFFDateTime as String,
                value: "\(dateTime)",
                displayName: "Modified Date/Time"
            ))
        }

        return metadata
    }

    private func parseIPTCData(_ iptcDict: [String: Any]) -> [ExifMetadata] {
        var metadata: [ExifMetadata] = []

        for (key, value) in iptcDict {
            metadata.append(ExifMetadata(
                category: .other,
                key: key,
                value: "\(value)",
                displayName: key.replacingOccurrences(of: "IPTC", with: "").replacingOccurrences(of: ":", with: " ")
            ))
        }

        return metadata
    }

    private func parseBasicProperties(_ properties: [String: Any]) -> [ExifMetadata] {
        var metadata: [ExifMetadata] = []

        if let width = properties[kCGImagePropertyPixelWidth as String] {
            metadata.append(ExifMetadata(
                category: .other,
                key: kCGImagePropertyPixelWidth as String,
                value: "\(width) px",
                displayName: "Width"
            ))
        }

        if let height = properties[kCGImagePropertyPixelHeight as String] {
            metadata.append(ExifMetadata(
                category: .other,
                key: kCGImagePropertyPixelHeight as String,
                value: "\(height) px",
                displayName: "Height"
            ))
        }

        if let colorModel = properties[kCGImagePropertyColorModel as String] {
            metadata.append(ExifMetadata(
                category: .software,
                key: kCGImagePropertyColorModel as String,
                value: "\(colorModel)",
                displayName: "Color Model"
            ))
        }

        if let dpiWidth = properties[kCGImagePropertyDPIWidth as String] {
            metadata.append(ExifMetadata(
                category: .other,
                key: kCGImagePropertyDPIWidth as String,
                value: "\(dpiWidth) DPI",
                displayName: "Resolution (Width)"
            ))
        }

        if let dpiHeight = properties[kCGImagePropertyDPIHeight as String] {
            metadata.append(ExifMetadata(
                category: .other,
                key: kCGImagePropertyDPIHeight as String,
                value: "\(dpiHeight) DPI",
                displayName: "Resolution (Height)"
            ))
        }

        return metadata
    }
}
