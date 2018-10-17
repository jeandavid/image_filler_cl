//
//  ImageFillerWrapper.swift
//  ImageFillerCL
//
//  Created by Jean-David Morgenstern-Peirolo on 10/16/18.
//

import Cocoa
import ImageFiller

/// ImageFillerWrapper is responsible for converting between different image formats and calling the ImageFiller module
public struct ImageFillerWrapper {
    
    // MARK: Properties

    /// Original RGB image
    private let image: NSImage
    
    /// Optional Gray mask
    private let mask: NSImage?
    
    private let z: Int
    
    private let epsilon: Double
    
    private let connectivity: Int
    
    /// Width pixel dimension
    private var width: Int {
        let rep = image.representations[0]
        return rep.pixelsWide
    }
    
    /// Height pixel dimension
    private var height: Int {
        let rep = image.representations[0]
        return rep.pixelsHigh
    }
    
    private var size: Int {
        return width * height
    }
    
    private var bitmap: CGImage? {
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    public init(image: NSImage, z: Int, epsilon: Double, connectivity: Int, mask: NSImage? = nil) {
        self.image = image
        self.z = z
        self.epsilon = epsilon
        self.connectivity = connectivity
        self.mask = mask
    }
    
    // MARK: Main API
    
    public func run() throws {
        // Step 1
        //
        // Convert input RGB Image to gray scale bitmap
        // Convert gray scale bitmap to a GrayImage ready to be used by the ImageFiller module
        //
        guard let rgbBitmap: CGImage = bitmap, let grayBitmap: CGImage = convertToGrayScale(rgbBitmap) else {
            throw Error.failToConvertInputImageToGrayScale
        }
        let pixelData: [UInt8] = convertBitmapToPixels(grayBitmap)
        
        // Step 2
        //
        // If there is a mask, then merge it with the input (turned gray) image
        // If not, create a mask placed at (100,100) of dimension 20*20
        //
        var grayImage: GrayImage!
        if let mask = mask, let maskBitmap = mask.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            let maskData: [UInt8] = convertBitmapToPixels(maskBitmap)
            grayImage = merge(pixelData: pixelData, maskData: maskData)
        } else {
            grayImage = insertHole(pixelData: pixelData)
        }
        
        // Step 3
        //
        // Call the ImageFiller module that fills the hole and returns a filled GrayImage
        //
        let imageFiller = ImageFiller(image: grayImage, weight: weightCalculator(), connectivity: 8)
        let filledGrayImage: GrayImage = imageFiller.fill()
        
        // Step 4
        //
        // Convert the filled GrayImage back to a bitmap and wrtie it to a file named "filled.png" in the current directory
        //
        let pixelDataFilled: [UInt8] = convertGrayImageToPixels(filledGrayImage)
        if let bitmapFilled = convertPixelsToBitmap(pixelDataFilled) {
            let filledURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/filled.png")
            try writeBitmapToFile(bitmapFilled, to: filledURL)
        }
    }
    
    // MARK: Conversion from RGB to Gray bitmap
    
    private func convertToGrayScale(_ rgbBitmap: CGImage) -> CGImage? {
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
    
    private func convertPixelsToBitmap(_ pixelData: [UInt8]) -> CGImage? {
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
    
    private func convertBitmapToPixels(_ bitmap: CGImage) -> [UInt8] {
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
    
    // MARK: Conversion between pixel data and GrayImage, basically rescaling from {[0,1], -1} to [0, 255]
    
    private func convertGrayImageToPixels(_ grayImage: GrayImage) -> [UInt8] {
        return grayImage.pixels.map { max(UInt8.min, UInt8($0.value * 255.0)) }
    }
    
    // MARK: Helpers

    private func insertHole(pixelData: [UInt8]) -> GrayImage {
        let start: Coordinate = (100, 100)
        let end: Coordinate = (120, 120)
        let box: Box = (start, end)
        let coordinator = Coordinator(width: width, height: height)
        var pixels = [Pixel]()
        pixelData.enumerated().forEach { (offset, originalValue) in
            if coordinator.isInside(offset: offset, box: box) {
                pixels.append(Pixel(value: -1.0))
            } else {
                pixels.append(Pixel(value: Double(originalValue) / Double(UInt8.max)))
            }
        }
        return GrayImage(pixels: pixels, width: width, height: height)
    }
    
    private func merge(pixelData: [UInt8], maskData: [UInt8]) -> GrayImage {
        var pixels = [Pixel]()
        pixelData.enumerated().forEach { (offset, originalValue) in
            if maskData[offset] == UInt8.min {
                pixels.append(Pixel(value: -1.0))
            } else {
                pixels.append(Pixel(value: Double(originalValue) / Double(UInt8.max)))
            }
        }
        return GrayImage(pixels: pixels, width: width, height: height)
    }
    
    private func writeBitmapToFile(_ image: CGImage, to destinationURL: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else {throw Error.failToCreateImageDestination }
        CGImageDestinationAddImage(destination, image, nil)
        let result = CGImageDestinationFinalize(destination)
        if  !result {
            throw Error.failToWriteImage
        }
    }
    
    // MARK: Weight Function
    
    /// Returns the default weightFunction that depends of the input epsilon and z
    private func weightCalculator() -> WeightCalculator {
        return weightFunction
    }
    
    /// Euclidean Distance
    private func distance(first: Coordinate, second: Coordinate) -> Double {
        return sqrt(pow(Double(first.column - second.column), 2) + pow(Double(first.row - second.row), 2))
    }
    
    /// Default WeightFunction
    private func weightFunction(first: Coordinate, second: Coordinate) -> Double {
        return 1.0 / (pow(distance(first: first, second: second), Double(z)) + epsilon)
    }
}

// MARK: Custom Error

extension ImageFillerWrapper {
    enum Error: Swift.Error {
        case failToConvertInputImageToGrayScale
        case failToCreateImageDestination
        case failToWriteImage
    }
}
