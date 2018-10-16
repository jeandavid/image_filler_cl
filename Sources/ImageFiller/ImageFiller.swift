import Foundation

typealias WeightCalculator = (Pixel, Pixel) -> Double

/// Intput: GrayImage, Weight, Connectivity
/// Output: GrayImage ( call fill() )
struct ImageFiller {

    private let image: GrayImage
    private let weight: WeightCalculator
    private let pixelConnectivity: PixelConnectivity

    var hole = Set<Offset>()
    var boundary = Set<Offset>()

    init(image: GrayImage, weight: @escaping WeightCalculator, pixelConnectivity: PixelConnectivity) {
        self.image = image
        self.weight = weight
        self.pixelConnectivity = pixelConnectivity
        setupHole()
        setupBoundary()
    }

    mutating func setupHole() {
        self.hole = Set(self.image.hole)
    }

    mutating func setupBoundary() {
        self.hole.forEach { (offset) in
            let coordinate = image.convertOffsetToCoordinate(offset)
            // Coordinates of all pixels that are connected to pixel at specific @offset but not in hole themselves
            let connectedCoordinates = pixelConnectivity.connectedCoordinates(for: coordinate).filter({ coordinate in
                guard let pixel = self.image.pixel(at: coordinate) else {return false}
                return !pixel.isHole
            })
            // insert offsets that are not already in hole to boundary
            connectedCoordinates.map { image.convertCoordinateToOffset($0) }.forEach({ (offset) in
                if !self.hole.contains(offset) {
                    self.boundary.insert(offset)
                }
            })

        }
    }

    func fill() -> GrayImage {
        let pixels: [Pixel] = image.pixels.enumerated().map({ (offset, pixel) in
            if hole.contains(offset) {
                return color(pixel)
            } else {
                return pixel
            }
        })
        return GrayImage(pixels: pixels, width: image.width, height: image.height)
    }

    private func color(_ pixel: Pixel) -> Pixel {
        var top: Double = 0
        // TODO: reduce
        for offset in boundary {
            if let pixelAtBoundary = image.pixel(at: offset) {
                top += weight(pixel, pixelAtBoundary) * pixelAtBoundary.value
            }
        }
        var bottom: Double = 0
        // TODO: reduce
        for offset in boundary {
            if let pixelAtBoundary = image.pixel(at: offset) {
                bottom += weight(pixel, pixelAtBoundary)
            }
        }
        // make sure bottom is not nil else return unchanged pixel
        guard bottom != 0 else {return pixel}
        return Pixel(value: top / bottom)
    }
}
