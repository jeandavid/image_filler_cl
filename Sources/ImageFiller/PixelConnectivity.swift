import Foundation

enum PixelConnectivity {
    case four
    case eight

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
