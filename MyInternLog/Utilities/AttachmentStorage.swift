import UIKit

// Saves images to the app's Documents directory so they persist across relaunches.
// localPath in AttachmentItem stores the filename; the directory is resolved at runtime.
enum AttachmentStorage {

    static func save(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let fileName = UUID().uuidString + ".jpg"
        let url = documentsURL.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return fileName
        } catch {
            return nil
        }
    }

    static func load(fileName: String) -> UIImage? {
        let url = documentsURL.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func delete(fileName: String) {
        let url = documentsURL.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }

    private static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
