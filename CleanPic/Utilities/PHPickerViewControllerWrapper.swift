import SwiftUI
import PhotosUI

struct PHPickerViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onImagesSelected: ([(UIImage, Data, PHAsset?)]) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let container = UIViewController()
        return container
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.selectionLimit = 50
            config.filter = .images

            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator

            DispatchQueue.main.async {
                uiViewController.present(picker, animated: true)
            }
        } else if !isPresented && uiViewController.presentedViewController != nil {
            DispatchQueue.main.async {
                uiViewController.dismiss(animated: true)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PHPickerViewControllerWrapper

        init(_ parent: PHPickerViewControllerWrapper) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            DispatchQueue.main.async {
                self.parent.isPresented = false
            }

            guard !results.isEmpty else {
                print("📸 User canceled photo selection")
                return
            }

            print("📸 Loading \(results.count) photos...")

            let group = DispatchGroup()
            var loadedImages: [(UIImage, Data, PHAsset?)] = []
            let lock = NSLock()

            for (index, result) in results.enumerated() {
                group.enter()

                let assetIdentifier = result.assetIdentifier
                let phAsset: PHAsset?

                if let identifier = assetIdentifier {
                    let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
                    phAsset = fetchResult.firstObject
                    print("📸 Loading photo \(index + 1): asset ID = \(identifier)")
                    if phAsset != nil {
                        print("✅ Found PHAsset for photo \(index + 1)")
                    } else {
                        print("⚠️ PHAsset not found for identifier: \(identifier)")
                    }
                } else {
                    phAsset = nil
                    print("⚠️ Photo \(index + 1): No asset identifier")
                }

                result.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [phAsset] data, error in
                    if let error = error {
                        print("❌ Error loading data \(index + 1): \(error.localizedDescription)")
                        group.leave()
                        return
                    }

                    guard let imageData = data else {
                        print("❌ No image data for photo \(index + 1)")
                        group.leave()
                        return
                    }

                    guard let uiImage = UIImage(data: imageData) else {
                        print("❌ Could not create UIImage from data for photo \(index + 1)")
                        group.leave()
                        return
                    }

                    print("✅ Successfully loaded photo \(index + 1) (\(imageData.count) bytes)")

                    lock.lock()
                    loadedImages.append((uiImage, imageData, phAsset))
                    lock.unlock()

                    group.leave()
                }
            }

            group.notify(queue: .main) { [weak self] in
                print("✅ Loaded \(loadedImages.count) photos")
                self?.parent.onImagesSelected(loadedImages)
            }
        }
    }
}
