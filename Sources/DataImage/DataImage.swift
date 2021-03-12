//
//  DataImage.swift
//  recipes
//
//  Created by Lucas Assis Rodrigues on 13.02.21.
//

import Foundation
import SwiftUI

// MARK: - DataImageCache

private enum DataImageCache {
    private static var shared: NSCache<NSData, UIImage> = {
        let cache = NSCache<NSData, UIImage>()
        cache.countLimit = 20
        return cache
    }()

    static subscript(_ data: Data) -> UIImage? {
        get { shared.object(forKey: data as NSData) }
        set {
            newValue.map { shared.setObject($0, forKey: data as NSData) }
                ?? shared.removeObject(forKey: data as NSData)
        }
    }
}

// MARK: - DataImage

public struct DataImage<Placeholder>: View where Placeholder: View {
    #if os(macOS)
        private typealias UIImage = NSImage
    #endif

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
    private let imageTransition: AnyTransition
    private let isResizable: Bool
    private let aspectRatio: CGFloat?
    private let contentMode: ContentMode
    private let placeholder: () -> Placeholder

    public var body: some View {
        if let image = viewModel.image {
            imageView(image: image)
                .aspectRatio(aspectRatio, contentMode: contentMode)
                .transition(imageTransition)
        } else {
            placeholder().transition(imageTransition)
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
        contentMode: ContentMode = .fill,
        imageTransition: AnyTransition = AnyTransition.scale.animation(.spring()),
        placeholder: @escaping () -> Placeholder
    ) {
        self._viewModel = .init(wrappedValue: .init(data: data))
        self.isResizable = isResizable
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.imageTransition = imageTransition
        self.placeholder = placeholder
    }

    init(
        data: Data,
        isResizable: Bool = true,
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode = .fill,
        imageTransition: AnyTransition = AnyTransition.scale.animation(.spring()),
        placeholder: @autoclosure @escaping () -> Placeholder
    ) {
        self.init(
            data: data,
            isResizable: isResizable,
            aspectRatio: aspectRatio,
            contentMode: contentMode,
            imageTransition: imageTransition,
            placeholder: placeholder
        )
    }
}

// MARK: - DataImage + UIImage

extension DataImage where Placeholder == EmptyView {
    init(
        image: UIImage,
        isResizable: Bool = true,
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode = .fill,
        imageTransition: AnyTransition = AnyTransition.scale.animation(.spring())
    ) {
        self._viewModel = .init(wrappedValue: .init(image: image))
        self.isResizable = isResizable
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.imageTransition = imageTransition
        self.placeholder = EmptyView.init
    }
}

// MARK: - DataImage_Previews

struct DataImage_Previews: PreviewProvider {
    static var previews: some View {
        DataImage(data: .init()) { EmptyView() }
    }
}
