//
//  CommandLineTool.swift
//  ImageFillerCL
//
//  Created by Jean-David Morgenstern-Peirolo on 10/16/18.
//

import Foundation
import Cocoa
import ImageFiller

struct CommandLineTool {
    private let arguments: [String]
    
    init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    func run() throws {
        guard arguments.count > 1 else {
            throw Error.missingFileName
        }
        
        guard arguments.count == 2 else {
            print("Wrong number of arguments")
            throw Error.failedToCreateFile
        }
        
        let filename = arguments[1]
        guard let nsImage = NSImage(byReferencingFile: filename) else {
            throw Error.failToReadImage
        }
        
        let imageFillerWrapper = ImageFillerWrapper(image: nsImage)
        
        let filledURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/filled2.png")
        if let rgbBitmap: CGImage = imageFillerWrapper.bitmap,
            let grayBitmap: CGImage = imageFillerWrapper.convertToGrayScale(rgbBitmap) {
            let pixelData: [UInt8] = imageFillerWrapper.convertBitmapToPixels(grayBitmap)
            let grayImage: GrayImage = imageFillerWrapper.convertPixelsToGrayImage(pixelData)
            let grayImageWithHole: GrayImage = imageFillerWrapper.insertHole(in: grayImage)
            let imageFiller = ImageFiller(image: grayImageWithHole, weight: imageFillerWrapper.weightCalculator(), connectivity: 8)
            let filledGrayImage: GrayImage = imageFiller.fill()
            let pixelDataFilled: [UInt8] = imageFillerWrapper.convertGrayImageToPixels(filledGrayImage)
            if let bitmapFilled = imageFillerWrapper.convertPixelsToBitmap(pixelDataFilled) {
                try imageFillerWrapper.writeBitmapToFile(bitmapFilled, to: filledURL)
            }
        }
        
        /*
        // Create a gray image with a hole in an rgb image, write it to file
        let holeURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/hole.png")
        if let rgbBitmap: CGImage = imageFillerWrapper.bitmap,
            let grayBitmap: CGImage = imageFillerWrapper.convertToGrayScale(rgbBitmap) {
            let pixelData: [UInt8] = imageFillerWrapper.convertBitmapToPixels(grayBitmap)
            let grayImage: GrayImage = imageFillerWrapper.convertPixelsToGrayImage(pixelData)
            let grayImageWithHole: GrayImage = imageFillerWrapper.insertHole(in: grayImage)
            let pixelDataWithHole: [UInt8] = imageFillerWrapper.convertGrayImageToPixels(grayImageWithHole)
            if let bitmapWithHole = imageFillerWrapper.convertPixelsToBitmap(pixelDataWithHole) {
                try imageFillerWrapper.writeBitmapToFile(bitmapWithHole, to: holeURL)
            }
        }
        */
        
        /*
        if let rgbBitmap: CGImage = imageFillerWrapper.bitmap,
            let grayBitmap: CGImage = imageFillerWrapper.convertToGrayScale(rgbBitmap) {
            let pixelData: [UInt8] = imageFillerWrapper.convertBitmapToPixels(grayBitmap)
            let grayImage: GrayImage = imageFillerWrapper.convertPixelsToGrayImage(pixelData)
            let mockPixelData: [UInt8] = imageFillerWrapper.mockHole(for: grayImage)
            if let mockBitmap: CGImage = imageFillerWrapper.convertPixelsToBitmap(mockPixelData) {
                try imageFillerWrapper.writeBitmapToFile(mockBitmap, to: mockURL)
            }
        }
        */
        
        //let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/gray.png")
        //if let rgbBitmap = imageFillerWrapper.bitmap,
        //    let grayBitmap = imageFillerWrapper.convertToGrayScale(rgbBitmap) {
        //    try imageFillerWrapper.writeBitmapToFile(grayBitmap, to: url)
        //}
        
        //if let rgbBitmap = imageFillerWrapper.bitmap,
        //    let grayBitmap = imageFillerWrapper.convertToGrayScale(rgbBitmap) {
        //    let pixels = imageFillerWrapper.convertBitmapToPixels(grayBitmap)
        //    print("pixels count: \(pixels.count)")
        //}
    }
}

extension CommandLineTool {
    enum Error: Swift.Error {
        case missingFileName
        case failedToCreateFile
        case failToReadImage
    }
}
