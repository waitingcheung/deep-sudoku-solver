//
//  CIUtilities.swift
//  Deep Sudoku Solver
//
//  Created by Wai Ting Cheung on 2017. 3. 20..
//  Copyright © 2017년 Wai Ting Cheung. All rights reserved.
//

import CoreImage
import Foundation
import UIKit

extension CIImage {
    func averageColor(rect: CGRect, context: CIContext) -> CIColor {
        let ciPixel = self.applyingFilter("CIAreaAverage", parameters: [kCIInputExtentKey: CIVector(cgRect: rect)])
        
        var colourData = [UInt8](repeating: 0, count: 4)
        
        context.render(ciPixel, toBitmap: &colourData, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height:1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        let red = CGFloat(colourData[0]) / CGFloat(colourData[3])
        let green = CGFloat(colourData[1]) / CGFloat(colourData[3])
        let blue = CGFloat(colourData[2]) / CGFloat(colourData[3])
        
        return CIColor(red: red, green: green, blue: blue)
    }
}

func isEmptyCell(image: UIImage, rect: CGRect) -> Bool {
    let ciImage = CIImage(image: image)
    let context = CIContext()
    let uiColor = ciImage!.averageColor(rect: rect, context: context)
    if uiColor.red >= 0.99 && uiColor.green >= 0.99 && uiColor.blue >= 0.99 {
        return true
    }
    return false
}

func convertToGrayScale(image: UIImage) -> UIImage {
    let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    let colorSpace = CGColorSpaceCreateDeviceGray()
    let width = image.size.width
    let height = image.size.height
    
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
    let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
    
    context!.draw(image.cgImage!, in: imageRect)
    let imageRef = context!.makeImage()
    let newImage = UIImage(cgImage: imageRef!)
    
    return newImage
}

func detectAndTransformImage(image: UIImage) -> UIImage {
    let ciImage = CIImage(image: image)
    let ciContext =  CIContext()
    let detector = CIDetector(ofType: CIDetectorTypeRectangle,
                              context: ciContext,
                              options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    let rect = detector?.features(in: ciImage!).first as! CIRectangleFeature
    
    let transformedImage = transformImagePerspective(ciImage: ciImage!, rect: rect)
    let outputImage = correctImagePerspective(ciImage: transformedImage, rect: rect)
    /*let cgImage: CGImage = {
     let context = CIContext(options: nil)
     return context.createCGImage(outputImage, from: outputImage.extent)!
     }()
     return UIImage(cgImage: cgImage)*/
    return UIImage(ciImage: outputImage)
}

func transformImagePerspective(ciImage: CIImage, rect: CIRectangleFeature) -> CIImage {
    let perspectiveTransform = CIFilter(name: "CIPerspectiveTransform")!
    perspectiveTransform.setValue(CIVector(cgPoint:rect.topLeft), forKey: "inputTopLeft")
    perspectiveTransform.setValue(CIVector(cgPoint:rect.topRight), forKey: "inputTopRight")
    perspectiveTransform.setValue(CIVector(cgPoint:rect.bottomRight), forKey: "inputBottomRight")
    perspectiveTransform.setValue(CIVector(cgPoint:rect.bottomLeft), forKey: "inputBottomLeft")
    perspectiveTransform.setValue(ciImage, forKey: kCIInputImageKey)
    return perspectiveTransform.outputImage!
}

func correctImagePerspective(ciImage: CIImage, rect: CIRectangleFeature) -> CIImage {
    let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")!
    perspectiveCorrection.setValue(CIVector(cgPoint:rect.topLeft), forKey: "inputTopLeft")
    perspectiveCorrection.setValue(CIVector(cgPoint:rect.topRight), forKey: "inputTopRight")
    perspectiveCorrection.setValue(CIVector(cgPoint:rect.bottomRight), forKey: "inputBottomRight")
    perspectiveCorrection.setValue(CIVector(cgPoint:rect.bottomLeft), forKey: "inputBottomLeft")
    perspectiveCorrection.setValue(ciImage, forKey: kCIInputImageKey)
    return perspectiveCorrection.outputImage!
}
