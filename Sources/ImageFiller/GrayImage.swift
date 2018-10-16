import Foundation

typealias Offset = Int
typealias Coordinate = (column: Int, row: Int)

struct Pixel {
    var value: Double
    var isHole: Bool {
        return value == -1
    }
}

struct GrayImage {
    let pixels: [Pixel]
    let width: Int
    let height: Int

    var pixelCount: Int {
        return pixels.count
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
        return (offset % width, offset / width)
    }

    func convertCoordinateToOffset(_ coordinate: Coordinate) -> Offset {
        return coordinate.row * width + coordinate.column
    }

    func isOffsetOnTheEdge(_ offset: Offset) -> Bool {
        let coordinate = convertOffsetToCoordinate(offset)
        if coordinate.column == 0 || coordinate.column == width - 1 {
            return true
        }
        if coordinate.row == 0 || coordinate.column == height - 1 {
            return true
        }
        return false
    }
}
