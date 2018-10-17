import Foundation

/// Pixel Connectivity
enum PixelConnectivity: Int {
    case four = 4
    case eight = 8

    /// Based on the connectivity option, returns the coordinates of the connected pixels
    func connectedCoordinates(for coordinate: Coordinate) -> [Coordinate] {
        let top: Coordinate = (coordinate.column, coordinate.row - 1)
        let right: Coordinate = (coordinate.column + 1, coordinate.row)
        let left: Coordinate = (coordinate.column - 1, coordinate.row)
        let bottom: Coordinate = (coordinate.column, coordinate.row + 1)
        var coordinates = [top, right, left, bottom]
        if self == .eight {
            let topLeft: Coordinate = (coordinate.column - 1, coordinate.row - 1)
            let topRight: Coordinate = (coordinate.column + 1, coordinate.row - 1)
            let bottomRight: Coordinate = (coordinate.column + 1, coordinate.row + 1)
            let bottomLeft: Coordinate = (coordinate.column - 1, coordinate.row + 1)
            coordinates += [topLeft, topRight, bottomRight, bottomLeft]
        }
        return coordinates
    }
}
