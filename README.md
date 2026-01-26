# CleanPic

Privacy-first iOS app to remove EXIF metadata from photos before sharing. Completely free and open source.

## Features

- **Inspect Metadata**: View all EXIF data embedded in your photos, organized by category
- **Batch Processing**: Clean multiple photos at once with intelligent progress tracking
- **One-Tap Removal**: Remove all metadata with a single tap
- **Smart Deletion**: Option to delete original photos after cleaning
- **Beautiful Interface**: Modern, dark mode UI with smooth animations
- **Completely Offline**: All processing happens on your device

## Metadata Categories

CleanPic displays and removes metadata across these categories:

- **Location**: GPS coordinates, altitude, timestamps
- **Device**: Make, model, OS version
- **Camera Settings**: Focal length, aperture, ISO, shutter speed, lens info
- **Date & Time**: Original, digitized, and modified timestamps
- **Software**: Processing software, color space
- **Other**: Dimensions, resolution, orientation

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Build Instructions

1. Install XcodeGen:
   ```bash
   brew install xcodegen
   ```

2. Generate Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open project in Xcode:
   ```bash
   open CleanPic.xcodeproj
   ```

4. Build and run on simulator or device

## Technical Stack

- **SwiftUI**: Modern declarative UI framework
- **PhotosUI**: PhotosPicker for image selection
- **ImageIO**: Metadata reading and stripping
- **Photos**: Photo library integration

## Architecture

- **MVVM Pattern**: Clean separation of concerns
- **Service Layer**: ExifReaderService, ExifPurgeService, PhotoLibraryService
- **Theme System**: Centralized colors and typography

## Privacy Policy

**Last Updated: January 25, 2026**

CleanPic is committed to protecting your privacy. This privacy policy explains our data practices.

### Data Collection

**CleanPic collects ZERO data.** We do not collect, store, transmit, or share any of your personal information or photos.

### What CleanPic Does

- Reads photo metadata locally on your device
- Removes metadata from photos locally on your device
- Saves cleaned photos to your device's photo library
- All processing happens entirely offline on your device

### What CleanPic Does NOT Do

- Does not upload your photos to any server
- Does not collect analytics or usage data
- Does not track your location
- Does not use third-party SDKs or trackers
- Does not require an internet connection
- Does not create user accounts
- Does not store your photos outside your device

### Permissions

CleanPic requests the following permissions:

- **Photo Library Access**: Required to read photos you select and save cleaned versions back to your library. Photos are processed locally and never leave your device.

### Open Source

CleanPic is 100% open source. You can inspect the entire source code to verify our privacy claims. There are no hidden data collection mechanisms.

### Contact

If you have questions about this privacy policy, please open an issue on this GitHub repository.

### Changes to This Policy

Any changes to this privacy policy will be posted to this repository. Continued use of the app after changes constitutes acceptance of those changes.

## License

MIT License - Free and open source.
