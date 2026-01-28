import Photos
import UIKit

class PhotoLibraryService {
    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status == .authorized || status == .limited
    }

    func hasFullAccess() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return status == .authorized
    }

    func saveImage(_ imageData: Data) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: imageData, options: nil)
        }
    }

    func deleteAsset(_ asset: PHAsset) async throws {
        guard hasFullAccess() else {
            throw PhotoLibraryError.insufficientPermissions
        }

        print("🗑️ Deleting asset: \(asset.localIdentifier)")

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }

        print("✅ Asset deleted successfully")
    }

    func deleteAssets(_ assets: [PHAsset]) async throws {
        guard hasFullAccess() else {
            throw PhotoLibraryError.insufficientPermissions
        }

        print("🗑️ Deleting \(assets.count) assets")

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }

        print("✅ \(assets.count) assets deleted successfully")
    }
}

enum PhotoLibraryError: LocalizedError {
    case insufficientPermissions

    var errorDescription: String? {
        switch self {
        case .insufficientPermissions:
            return "Full photo library access is required to delete photos. Please go to Settings > CleanPic > Photos and select \"Full Access\"."
        }
    }
}
