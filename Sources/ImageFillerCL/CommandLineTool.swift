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

/// CommandLineTool is responsible for parsing the command line arguments,
/// initializing the image filler wrapper and running it
struct CommandLineTool {
    private let arguments: [String]
    
    init(arguments: [String] = Array(CommandLine.arguments.dropFirst())) {
        self.arguments = arguments
    }

    func run() throws {
        let parser = ArgumentParser(usage: "imageFile <options>", overview: "This library fills holes in images. Pass a RGB input image, an optional mask, it will output a filled image written in the current directory")
        
        let imageFileArg: PositionalArgument<String> = parser.add(positional: "imageFile", kind: String.self)
        let zArg: OptionArgument<Int> = parser.add(option: "--zexponent", shortName: "-z", kind: Int.self, usage: "Exponent for the weight function. Default to 4")
        let epsilonArg: OptionArgument<String> = parser.add(option: "--epsilon", shortName: "-e", kind: String.self, usage: "Epsilon for the weight function. Default to 1e-9")
        let connectivityArg: OptionArgument<Int> = parser.add(option: "--connectivity", shortName: "-c", kind: Int.self, usage: "Pixel Connectivity. Default to 8")
        let maskArg: OptionArgument<String> = parser.add(option: "--mask", shortName: "-m", kind: String.self, usage: "Mask that defines the hole. It should be a grayscale image. Black pixel will be considered as a mask. If a mask is not provided, then we will use a mock of dimension 20*20, placed at (100,100). Minimum size for the original image should therefore be 120*120")
        
        let parsedArguments = try parser.parse(arguments)
        
        guard let imageFile = parsedArguments.get(imageFileArg) else {
            throw Error.missingImageFilenameArgument
        }
        
        let z: Int = parsedArguments.get(zArg) ?? 4
        
        var epsilon: Double = 1e-9
        if let epsilonString = parsedArguments.get(epsilonArg), let eps = Double(epsilonString) {
            epsilon = eps
        }
        
        let connectivity = parsedArguments.get(connectivityArg) ?? 8
        
        let maskFile = parsedArguments.get(maskArg)
        
        guard let nsImage = NSImage(byReferencingFile: imageFile) else {
            throw Error.failToReadImage
        }
        
        var nsMask: NSImage?
        if let maskFile = maskFile {
            nsMask = NSImage(byReferencingFile: maskFile)
        }
        
        let imageFillerWrapper = ImageFillerWrapper(image: nsImage, z: z, epsilon: epsilon, connectivity: connectivity, mask: nsMask)
        try imageFillerWrapper.run()
    }
}

extension CommandLineTool {
    enum Error: Swift.Error {
        case missingImageFilenameArgument
        case failToReadImage
    }
}
