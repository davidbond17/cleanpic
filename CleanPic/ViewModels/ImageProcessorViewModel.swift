import SwiftUI
import PhotosUI

@MainActor
class ImageProcessorViewModel: ObservableObject {
    @Published var originalImage: UIImage?
    @Published var imageData: Data?
    @Published var metadata: [ExifMetadata] = []
    @Published var batchPhotos: [BatchPhotoItem] = []
    @Published var isProcessing: Bool = false
    @Published var processingProgress: Double = 0.0
    @Published var processingStatus: String = ""
    @Published var processingResult: ProcessingResult?
    @Published var showSuccessAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var showDeleteOriginalAlert: Bool = false
    @Published var showDeletionSuccessAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""

    private var originalAsset: PHAsset?

    private let exifReaderService = ExifReaderService()
    private let exifPurgeService = ExifPurgeService()
    private let photoLibraryService = PhotoLibraryService()

    var isBatchMode: Bool {
        batchPhotos.count > 1
    }

    var totalMetadataCount: Int {
        batchPhotos.reduce(0) { $0 + $1.metadataCount }
    }

    func loadImages(_ images: [(UIImage, Data, PHAsset?)]) {
        batchPhotos = []
        isProcessing = true
        processingProgress = 0.0

        if images.count == 1 {
            let (image, data, asset) = images[0]
            originalAsset = asset
            imageData = data
            originalImage = image

            if let properties = exifReaderService.readMetadata(from: data) {
                metadata = exifReaderService.parseMetadata(properties)
            }
        } else {
            var items: [BatchPhotoItem] = []

            for (image, data, asset) in images {
                var item = BatchPhotoItem(image: image, imageData: data, asset: asset)

                if let properties = exifReaderService.readMetadata(from: data) {
                    item.metadata = exifReaderService.parseMetadata(properties)
                }

                items.append(item)
            }

            batchPhotos = items.sorted { $0.metadataCount > $1.metadataCount }
            print("📊 Loaded \(batchPhotos.count) photos, sorted by metadata count")
        }

        isProcessing = false
    }

    func purgeMetadata() async {
        isProcessing = true

        let authorized = await photoLibraryService.requestAuthorization()
        guard authorized else {
            errorMessage = "Photo library access denied. Please enable in Settings."
            showErrorAlert = true
            isProcessing = false
            return
        }

        if isBatchMode {
            await purgeBatchPhotos()
        } else {
            await purgeSinglePhoto()
        }
    }

    private func purgeSinglePhoto() async {
        guard let image = originalImage else {
            errorMessage = "No image loaded"
            showErrorAlert = true
            isProcessing = false
            return
        }

        guard let cleanedData = exifPurgeService.removeMetadata(from: image) else {
            errorMessage = "Failed to remove metadata"
            showErrorAlert = true
            isProcessing = false
            return
        }

        do {
            try await photoLibraryService.saveImage(cleanedData)
            processingResult = .success
            showDeleteOriginalAlert = true
        } catch {
            processingResult = .failure(error)
            errorMessage = "Failed to save image: \(error.localizedDescription)"
            showErrorAlert = true
        }

        isProcessing = false
    }

    private func purgeBatchPhotos() async {
        processingProgress = 0.0
        let total = Double(batchPhotos.count)
        var successCount = 0

        for (index, photo) in batchPhotos.enumerated() {
            let current = index + 1
            processingStatus = "Processing photo \(current) of \(batchPhotos.count)..."
            processingProgress = Double(current) / total

            print("🔄 Processing photo \(current)/\(batchPhotos.count)")

            guard let cleanedData = exifPurgeService.removeMetadata(from: photo.image) else {
                print("❌ Failed to remove metadata from photo \(current)")
                continue
            }

            do {
                try await photoLibraryService.saveImage(cleanedData)
                successCount += 1
                print("✅ Saved photo \(current)")
            } catch {
                print("❌ Failed to save photo \(current): \(error.localizedDescription)")
            }
        }

        isProcessing = false
        processingProgress = 1.0

        if successCount == batchPhotos.count {
            processingResult = .success
            showDeleteOriginalAlert = true
        } else if successCount > 0 {
            successMessage = "Saved \(successCount) of \(batchPhotos.count) photos. Some photos failed to process."
            showDeleteOriginalAlert = true
        } else {
            errorMessage = "Failed to process any photos"
            showErrorAlert = true
        }
    }

    func deleteOriginalPhoto() async {
        if isBatchMode {
            await deleteBatchOriginals()
        } else {
            await deleteSingleOriginal()
        }
    }

    private func deleteSingleOriginal() async {
        guard let asset = originalAsset else {
            errorMessage = "Cannot delete the original photo. The photo might not be from your library."
            showErrorAlert = true
            return
        }

        print("🗑️ Attempting to delete asset: \(asset.localIdentifier)")

        do {
            try await photoLibraryService.deleteAsset(asset)
            print("✅ Successfully deleted original photo")
            successMessage = "Original photo deleted successfully. Your clean copy is saved in your library."
            showDeletionSuccessAlert = true
        } catch {
            print("❌ Deletion error: \(error.localizedDescription)")
            errorMessage = "Unable to delete original photo: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    private func deleteBatchOriginals() async {
        let assetsToDelete = batchPhotos.compactMap { $0.asset }

        guard !assetsToDelete.isEmpty else {
            errorMessage = "Cannot delete original photos. They might not be from your library."
            showErrorAlert = true
            return
        }

        print("🗑️ Attempting to delete \(assetsToDelete.count) assets")

        do {
            try await photoLibraryService.deleteAssets(assetsToDelete)
            print("✅ Successfully deleted \(assetsToDelete.count) original photos")
            successMessage = "Deleted \(assetsToDelete.count) original photos. Your clean copies are saved in your library."
            showDeletionSuccessAlert = true
        } catch {
            print("❌ Deletion error: \(error.localizedDescription)")
            errorMessage = "Unable to delete original photos: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    func reset() {
        originalImage = nil
        imageData = nil
        metadata = []
        batchPhotos = []
        isProcessing = false
        processingProgress = 0.0
        processingStatus = ""
        processingResult = nil
        showSuccessAlert = false
        showErrorAlert = false
        showDeleteOriginalAlert = false
        showDeletionSuccessAlert = false
        errorMessage = ""
        successMessage = ""
        originalAsset = nil
    }
}
