import Foundation

public typealias WeightCalculator = (Coordinate, Coordinate) -> Double

/// ImageFiller implements the algorithms to fill an image with a hole
public struct ImageFiller {
    
    // MARK: Properties

    private let image: GrayImage
    /// Weight assigns a non-negative double weight to a pair of pixel coordinates
    private let weight: WeightCalculator
    /// Pixels can be either 4- or 8-connected.
    private let pixelConnectivity: PixelConnectivity

    /// Set of all the hole pixel offsets.
    private var hole = Set<Offset>()
    /// Set of all the boundary pixel offsets.
    private var boundary = Set<Offset>()

    public init(image: GrayImage, weight: @escaping WeightCalculator, connectivity: Int) {
        self.image = image
        self.weight = weight
        self.pixelConnectivity = PixelConnectivity(rawValue: connectivity) ?? .four
        setupHole()
        setupBoundary()
    }
    
    // MARK: Setup

    mutating func setupHole() {
        self.hole = Set(self.image.hole)
    }
    
    /// A boundary pixel is defined as a pixel that is connected to a hole pixel, but is not in the hole itself.
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
    
    // MARK: Main API

    /// Returns a filled image
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
    
    // MARK: Helper
    
    /// Returns the new value of a hole pixel
    private func color(_ pixel: Pixel, at offset: Offset) -> Pixel {
        var top: Double = 0
        let coordinate = image.convertOffsetToCoordinate(offset)
        for boundaryOffset in boundary {
            if let pixelAtBoundary = image.pixel(at: boundaryOffset) {
                let boundaryCoordinate = image.convertOffsetToCoordinate(boundaryOffset)
                top += weight(coordinate, boundaryCoordinate) * pixelAtBoundary.value
            }
        }
        var bottom: Double = 0
        for boundaryOffset in boundary {
            let boundaryCoordinate = image.convertOffsetToCoordinate(boundaryOffset)
            bottom += weight(coordinate, boundaryCoordinate)
        }
        // make sure bottom is not nil else return unchanged pixel
        guard bottom != 0 else {return pixel}
        return Pixel(value: top / bottom)
    }
}
