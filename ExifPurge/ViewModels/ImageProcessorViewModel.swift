import SwiftUI
import PhotosUI

@MainActor
class ImageProcessorViewModel: ObservableObject {
    @Published var selectedImageItem: PhotosPickerItem?
    @Published var originalImage: UIImage?
    @Published var imageData: Data?
    @Published var metadata: [ExifMetadata] = []
    @Published var isProcessing: Bool = false
    @Published var processingResult: ProcessingResult?
    @Published var showSuccessAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    private let exifReaderService = ExifReaderService()
    private let exifPurgeService = ExifPurgeService()
    private let photoLibraryService = PhotoLibraryService()

    func loadImage(from item: PhotosPickerItem) async {
        isProcessing = true
        metadata = []
        processingResult = nil

        guard let data = await item.loadImageData() else {
            isProcessing = false
            return
        }

        imageData = data
        originalImage = UIImage(data: data)

        if let properties = exifReaderService.readMetadata(from: data) {
            metadata = exifReaderService.parseMetadata(properties)
        }

        isProcessing = false
    }

    func purgeMetadata() async {
        guard let image = originalImage else {
            errorMessage = "No image loaded"
            showErrorAlert = true
            return
        }

        isProcessing = true

        let authorized = await photoLibraryService.requestAuthorization()
        guard authorized else {
            errorMessage = "Photo library access denied. Please enable in Settings."
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
            showSuccessAlert = true
        } catch {
            processingResult = .failure(error)
            errorMessage = "Failed to save image: \(error.localizedDescription)"
            showErrorAlert = true
        }

        isProcessing = false
    }

    func reset() {
        selectedImageItem = nil
        originalImage = nil
        imageData = nil
        metadata = []
        isProcessing = false
        processingResult = nil
        showSuccessAlert = false
        showErrorAlert = false
        errorMessage = ""
    }
}
