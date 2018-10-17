import Foundation

public struct Pixel {
    public var value: Double
    
    public init(value: Double) {
        self.value = value
    }
    
    var isHole: Bool {
        return value == -1
    }
}

public struct GrayImage {
    public let pixels: [Pixel]
    public let coordinator: Coordinator
    
    public init(pixels: [Pixel], width: Int, height: Int) {
        self.pixels = pixels
        self.coordinator = Coordinator(width: width, height: height)
    }

    public var pixelCount: Int {
        return pixels.count
    }
    
    public var width: Int {
        return coordinator.width
    }
    
    public var height: Int {
        return coordinator.height
    }

    var hole: [Offset] {
        return pixels.enumerated().compactMap { (offset: Offset, pixel: Pixel) in
            guard pixel.isHole else {return nil}
            // Do not handle holes on the edges, i.e just ignore them
            guard !isOffsetOnTheEdge(offset) else {return nil}
            // At this point, Pixel is a hole, not on the edge; let's return its offset
            return offset
        }
    }

    func pixel(at offset: Offset) -> Pixel? {
        guard case 0..<pixels.count = offset else {return nil}
        return pixels[offset]
    }

    func pixel(at coordinate: Coordinate) -> Pixel? {
        let offset = convertCoordinateToOffset(coordinate)
        return pixel(at: offset)
    }

    func convertOffsetToCoordinate(_ offset: Offset) -> Coordinate {
        return coordinator.coordinate(for: offset)
    }

    func convertCoordinateToOffset(_ coordinate: Coordinate) -> Offset {
        return coordinator.offset(for: coordinate)
    }

    func isOffsetOnTheEdge(_ offset: Offset) -> Bool {
        return !coordinator.isInside(offset: offset)
    }
}
