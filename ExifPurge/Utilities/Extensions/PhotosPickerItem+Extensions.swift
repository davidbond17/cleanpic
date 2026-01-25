import PhotosUI
import UIKit

extension PhotosPickerItem {
    func loadImageData() async -> Data? {
        guard let data = try? await self.loadTransferable(type: Data.self) else {
            return nil
        }
        return data
    }

    func loadUIImage() async -> UIImage? {
        guard let data = await loadImageData() else {
            return nil
        }
        return UIImage(data: data)
    }
}
