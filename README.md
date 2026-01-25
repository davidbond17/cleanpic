# ExifPurge

Privacy-first iOS app to remove EXIF metadata from photos before sharing.

## Features

- **Analyze Metadata**: View all EXIF data embedded in your photos
- **Complete Removal**: Strip GPS location, device info, camera settings, and more
- **One-Tap Purge**: Clean your photos with a single tap
- **Original Preserved**: Your original photos remain untouched
- **Security Aesthetic**: Dark mode UI with monospaced fonts

## Metadata Categories

ExifPurge displays and removes metadata across these categories:

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
   open ExifPurge.xcodeproj
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

## Privacy

- No data collection
- No network requests
- All processing happens locally
- Photos never leave your device

## License

Private portfolio project.
