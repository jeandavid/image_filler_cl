import Foundation

public typealias WeightCalculator = (Coordinate, Coordinate) -> Double

/// Intput: GrayImage, Weight, Connectivity
/// Output: GrayImage ( call fill() )
public struct ImageFiller {

    private let image: GrayImage
    private let weight: WeightCalculator
    private let pixelConnectivity: PixelConnectivity

    var hole = Set<Offset>()
    var boundary = Set<Offset>()

    public init(image: GrayImage, weight: @escaping WeightCalculator, connectivity: Int) {
        self.image = image
        self.weight = weight
        self.pixelConnectivity = PixelConnectivity(rawValue: connectivity) ?? .four
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

    public func fill() -> GrayImage {
        let pixels: [Pixel] = image.pixels.enumerated().map({ (offset, pixel) in
            if hole.contains(offset) {
                return color(pixel, at: offset)
            } else {
                return pixel
            }
        })
        return GrayImage(pixels: pixels, width: image.width, height: image.height)
    }

    private func color(_ pixel: Pixel, at offset: Offset) -> Pixel {
        var top: Double = 0
        let coordinate = image.convertOffsetToCoordinate(offset)
        // TODO: reduce
        for boundaryOffset in boundary {
            if let pixelAtBoundary = image.pixel(at: boundaryOffset) {
                let boundaryCoordinate = image.convertOffsetToCoordinate(boundaryOffset)
                top += weight(coordinate, boundaryCoordinate) * pixelAtBoundary.value
            }
        }
        var bottom: Double = 0
        // TODO: reduce
        for boundaryOffset in boundary {
            let boundaryCoordinate = image.convertOffsetToCoordinate(boundaryOffset)
            bottom += weight(coordinate, boundaryCoordinate)
        }
        // make sure bottom is not nil else return unchanged pixel
        guard bottom != 0 else {return pixel}
        return Pixel(value: top / bottom)
    }
}
