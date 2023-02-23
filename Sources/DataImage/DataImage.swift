import SwiftUI

// MARK: - DataImageCache

public enum DataImageCache {
    public static var shared: NSCache<NSData, UIImage>? = {
        let cache = NSCache<NSData, UIImage>()
        cache.countLimit = 20
        return cache
    }()

    public static subscript(_ data: Data) -> UIImage? {
        get { shared?.object(forKey: data as NSData) }
        set {
            newValue.flatMap { shared?.setObject($0, forKey: data as NSData) }
                ?? shared?.removeObject(forKey: data as NSData)
        }
    }
}

// MARK: - DataImage

public struct DataImage: View {
    private final class ViewModel: ObservableObject {
        @Published var image: UIImage?

        init(image: UIImage) {
            self.image = image
            image.pngData().map { DataImageCache[$0] = image }
        }

        init(data: Data) {
            DataImageCache[data].map { image = $0 }
                ?? DispatchQueue.global(qos: .userInteractive).async {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.image = image
                        DataImageCache[data] = image
                    }
                }
        }
    }

    @StateObject private var viewModel: ViewModel
    private let isResizable: Bool
    private let aspectRatio: CGFloat?
    private let contentMode: ContentMode

    public var body: some View {
        if let image = viewModel.image {
            imageView(image: image)
                .aspectRatio(aspectRatio, contentMode: contentMode)
        }
    }

    private func imageView(image: UIImage) -> Image {
        let imageView: Image
        #if os(macOS)
            imageView = Image(nsImage: image)
        #else
            imageView = Image(uiImage: image)
        #endif

        return isResizable ? imageView.resizable() : imageView
    }
}

// MARK: - DataImage + Initialization

public extension DataImage {
    init(
        data: Data,
        isResizable: Bool = true,
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode = .fill
    ) {
        self._viewModel = .init(wrappedValue: .init(data: data))
        self.isResizable = isResizable
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
    }
}


// MARK: - DataImage_Previews

struct DataImage_Previews: PreviewProvider {
    static var previews: some View {
        DataImage(data: .init())
    }
}

#if os(macOS)
    public typealias UIImage = NSImage
    extension NSImage {
        func pngData() -> Data? {
            cgImage(forProposedRect: nil, context: nil, hints: nil)
                .map(NSBitmapImageRep.init)?
                .representation(using: NSBitmapImageRep.FileType.png, properties: [:])
        }
    }
#endif
