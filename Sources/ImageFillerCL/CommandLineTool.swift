//
//  CommandLineTool.swift
//  ImageFillerCL
//
//  Created by Jean-David Morgenstern-Peirolo on 10/16/18.
//

import Foundation
import Cocoa
import ImageFiller
import Utility

struct CommandLineTool {
    private let arguments: [String]
    
    init(arguments: [String] = Array(CommandLine.arguments.dropFirst())) {
        self.arguments = arguments
    }

    func run() throws {
        
        let parser = ArgumentParser(usage: "imageFile <options>", overview: "This library fills holes in images.")
        
        let imageFileArg: PositionalArgument<String> = parser.add(positional: "imageFile", kind: String.self)
        let zArg: OptionArgument<Int> = parser.add(option: "--zexponent", shortName: "-z", kind: Int.self, usage: "Exponent for the weight function. Default to 2")
        let epsilonArg: OptionArgument<String> = parser.add(option: "--epsilon", shortName: "-e", kind: String.self, usage: "Epsilon for the weight function. Default to 1e-9")
        let connectivityArg: OptionArgument<Int> = parser.add(option: "--connectivity", shortName: "-c", kind: Int.self, usage: "Pixel Connectivity. Default to 4")
        
        let parsedArguments = try parser.parse(arguments)
        
        guard let imageFile = parsedArguments.get(imageFileArg) else {
            throw Error.missingImageFilenameArgument
        }
        
        let z: Int = parsedArguments.get(zArg) ?? 2
        
        var epsilon: Double = 1e-9
        if let epsilonString = parsedArguments.get(epsilonArg), let eps = Double(epsilonString) {
            epsilon = eps
        }
        
        let connectivity = parsedArguments.get(connectivityArg) ?? 4
        
        guard let nsImage = NSImage(byReferencingFile: imageFile) else {
            throw Error.failToReadImage
        }
        
        let imageFillerWrapper = ImageFillerWrapper(image: nsImage, z: z, epsilon: epsilon, connectivity: connectivity)
        
        let filledURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/filled3.png")
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
    }
}

extension CommandLineTool {
    enum Error: Swift.Error {
        case missingImageFilenameArgument
        case failToReadImage
    }
}
