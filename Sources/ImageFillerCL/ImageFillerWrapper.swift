//
//  ImageFillerWrapper.swift
//  ImageFillerCL
//
//  Created by Jean-David Morgenstern-Peirolo on 10/16/18.
//

import Cocoa

struct ImageFillerWrapper {

    let image: NSImage
    
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
    
    func convertPixelsToBitmap(_ pixels: [UInt8]) -> CGImage? {
        var bitmap: CGImage?
        let colorSpace = CGColorSpaceCreateDeviceGray()
        pixels.withUnsafeBytes { ptr in
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
    
    func writeBitmapToFile(_ image: CGImage, to destinationURL: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else {throw Error.failToCreateImageDestination }
        CGImageDestinationAddImage(destination, image, nil)
        let result = CGImageDestinationFinalize(destination)
        if  !result {
            throw Error.failToWriteImage
        }
    }
    
    // MARK: Weight Function
    
    
}

extension ImageFillerWrapper {
    enum Error: Swift.Error {
        case failToConvertToCGImage
        case failToConvertToGray
        case failToCreateImageDestination
        case failToWriteImage
    }
}
