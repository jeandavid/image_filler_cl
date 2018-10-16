//
//  CommandLineTool.swift
//  ImageFillerCL
//
//  Created by Jean-David Morgenstern-Peirolo on 10/16/18.
//

import Foundation
import Cocoa

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
        
        print("Great number of args")
        
        let filename = arguments[1]
        guard let nsImage = NSImage(byReferencingFile: filename) else {
            throw Error.failToReadImage
        }
        
        let imageFillerWrapper = ImageFillerWrapper(image: nsImage)
        
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/gray.png")
        if let rgbBitmap = imageFillerWrapper.bitmap,
            let grayBitmap = imageFillerWrapper.convertToGrayScale(rgbBitmap) {
            try imageFillerWrapper.writeBitmapToFile(grayBitmap, to: url)
        }
        
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
