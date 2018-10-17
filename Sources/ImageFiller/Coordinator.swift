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
    
    // Strictly!
    public func isInside(coordinate: Coordinate, box: Box? = nil) -> Bool {
        let topLeft: Coordinate = box?.topLeft ?? (0,0)
        let bottomRight: Coordinate = box?.bottomRight ?? (width - 1, height - 1)
        return coordinate.column > topLeft.column &&
            coordinate.column < bottomRight.column &&
            coordinate.row > topLeft.row &&
            coordinate.row < bottomRight.row
    }
    
    public func isInside(offset: Offset, box: Box? = nil) -> Bool {
        return isInside(coordinate: coordinate(for: offset), box: box)
    }
}
