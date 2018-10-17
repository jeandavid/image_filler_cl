//
//  ImageFillerWrapper.swift
//  ImageFillerCL
//
//  Created by Jean-David Morgenstern-Peirolo on 10/16/18.
//

import Cocoa
import ImageFiller

struct ImageFillerWrapper {

    let image: NSImage
    
    let epsilon: Double
    
    let z: Int
    
    let connectivity: Int
    
    init(image: NSImage, epsilon: Double = 1e-9, z: Int = 2, connectivity: Int = 4) {
        self.image = image
        self.epsilon = epsilon
        self.z = z
        self.connectivity = connectivity
    }
    
    var width: Int {
        let rep = image.representations[0]
        return rep.pixelsWide
    }
    
    var height: Int {
        let rep = image.representations[0]
        return rep.pixelsHigh
    }
    
    var size: Int {
        return width * height
    }
    
    var bitmap: CGImage? {
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    // MARK: Conversion from RGB to Gray bitmap
    
    func convertToGrayScale(_ rgbBitmap: CGImage) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )
        
        let imageRect = NSMakeRect(0, 0, CGFloat(width), CGFloat(height))
        context?.draw(rgbBitmap, in: imageRect)
        return context?.makeImage()
    }
    
    // MARK: Conversion between bitmap and pixels for gray scale images
    
    func convertPixelsToBitmap(_ pixelData: [UInt8]) -> CGImage? {
        var bitmap: CGImage?
        let colorSpace = CGColorSpaceCreateDeviceGray()
        pixelData.withUnsafeBytes { ptr in
            let context = CGContext(data: UnsafeMutableRawPointer(mutating: ptr.baseAddress!),
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: width,
                                    space: colorSpace,
                                    bitmapInfo: 0)
            bitmap = context?.makeImage()
        }
        return bitmap
    }
    
    func convertBitmapToPixels(_ bitmap: CGImage) -> [UInt8] {
        var pixelData = [UInt8](repeating: 0, count: size)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: &pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width,
                                space: colorSpace,
                                bitmapInfo: 0)
        context?.draw(bitmap, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixelData
    }
    
    // MARK: Helpers
    
    func insertHole(in grayImage: GrayImage) -> GrayImage {
        let start: Coordinate = (200, 100)
        let end: Coordinate = (220, 120)
        let box: Box = (start, end)
        var pixelsWithHole = [Pixel]()
        grayImage.pixels.enumerated().forEach { (offset, pixel) in
            if grayImage.coordinator.isInside(offset: offset, box: box) {
                pixelsWithHole.append(Pixel(value: -1.0))
            } else {
                pixelsWithHole.append(pixel)
            }
        }
        return GrayImage(pixels: pixelsWithHole, width: grayImage.width, height: grayImage.height)
    }
    
    func convertGrayImageToPixels(_ grayImage: GrayImage) -> [UInt8] {
        return grayImage.pixels.map { max(UInt8.min, UInt8($0.value * 255.0)) }
    }
    
    func convertPixelsToGrayImage(_ pixelData: [UInt8]) -> GrayImage {
        let pixels: [Pixel] = pixelData.map { Pixel(value: Double($0) / Double(UInt8.max)) }
        return GrayImage(pixels: pixels, width: width, height: height)
    }
    
    func writeBitmapToFile(_ image: CGImage, to destinationURL: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else {throw Error.failToCreateImageDestination }
        CGImageDestinationAddImage(destination, image, nil)
        let result = CGImageDestinationFinalize(destination)
        if  !result {
            throw Error.failToWriteImage
        }
    }
    
    func mockHole(for grayImage: GrayImage) -> [UInt8] {
        let start: Coordinate = (100, 100)
        let end: Coordinate = (120, 120)
        let box: Box = (start, end)
        var mock = [UInt8]()
        grayImage.pixels.enumerated().forEach { (offset, _) in
            if grayImage.coordinator.isInside(offset: offset, box: box) {
                mock.append(UInt8.min)
            } else {
                mock.append(UInt8.max)
            }
        }
        return mock
    }
    
    // MARK: Weight Function
    
    func weightCalculator() -> WeightCalculator {
        return weightFunction
    }
    
    /// Euclidean Distance
    func distance(first: Coordinate, second: Coordinate) -> Double {
        return sqrt(pow(Double(first.column - second.column), 2) + pow(Double(first.row - second.row), 2))
    }
    
    /// Default WeightFunction
    func weightFunction(first: Coordinate, second: Coordinate) -> Double {
        return 1.0 / (pow(distance(first: first, second: second), Double(z)) + epsilon)
    }
    
}

// MARK: Custom Error

extension ImageFillerWrapper {
    enum Error: Swift.Error {
        case failToConvertToCGImage
        case failToConvertToGray
        case failToCreateImageDestination
        case failToWriteImage
    }
}
