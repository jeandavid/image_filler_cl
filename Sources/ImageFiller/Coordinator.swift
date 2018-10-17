//
//  Coordinator.swift
//  ImageFiller
//
//  Created by Jean-David Morgenstern-Peirolo on 10/17/18.
//

import Foundation

public typealias Offset = Int
public typealias Coordinate = (column: Int, row: Int)
public typealias Box = (topLeft: Coordinate, bottomRight: Coordinate)

/// Coordinator converts between pixels offsets and coordinates
/// and provides helper methods to find out whether a pixel sits inside a specific rectangle
public struct Coordinator {
    let width: Int
    let height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    public func coordinate(for offset: Offset) -> Coordinate {
        return (offset % width, offset / width)
    }
    
    public func offset(for coordinate: Coordinate) -> Offset {
        return coordinate.row * width + coordinate.column
    }
    
    /// Returns whether a coordinate strictly! sits inside a box
    /// If box is not passed, then we consider the surrounding Box
    public func isInside(coordinate: Coordinate, box: Box? = nil) -> Bool {
        let topLeft: Coordinate = box?.topLeft ?? (0,0)
        let bottomRight: Coordinate = box?.bottomRight ?? (width - 1, height - 1)
        return coordinate.column > topLeft.column &&
            coordinate.column < bottomRight.column &&
            coordinate.row > topLeft.row &&
            coordinate.row < bottomRight.row
    }
    
    /// Returns whether a pixel at offset strictly! sits inside a box
    /// If box is not passed, then we consider the surrounding Box
    public func isInside(offset: Offset, box: Box? = nil) -> Bool {
        return isInside(coordinate: coordinate(for: offset), box: box)
    }
}
