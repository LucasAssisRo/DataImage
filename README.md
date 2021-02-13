# DataImage

Wrapper around **SwiftUI's** `Image` allowing asyncronous loading from `Data` objects.  

## Instalation
### Swift Package Manager
``` swift
 .package(url: "https://github.com/LucasAssisRo/DataImage", .branch("main"))
```

## Usage

```swift
Group {
    Image(data: someData) { PlaceholderView() }
    Image(image: someUIImage)
}
```
