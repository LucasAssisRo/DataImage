//
//  DataImage.swift
//  recipes
//
//  Created by Lucas Assis Rodrigues on 13.02.21.
//

import Foundation
import SwiftUI

// MARK: - DataImage

public struct DataImage<Placeholder>: View where Placeholder: View {
    #if os(macOS)
        private typealias UIImage = NSImage
    #endif

    private final class ViewModel: ObservableObject {
        @Published var image: UIImage?

        init(data: Data) {
            DispatchQueue.global(qos: .userInteractive).async {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.image = image
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
        isResizable: Bool = false,
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
        isResizable: Bool = false,
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

// MARK: - DataImage_Previews

struct DataImage_Previews: PreviewProvider {
    static var previews: some View {
        DataImage(data: .init()) { EmptyView() }
    }
}
