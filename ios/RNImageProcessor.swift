//
//  RNImageProcessor.swift
//  RNImageProcessor
//
//  Created by Elf on 08.05.2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import UIKit

@objc(RNImageProcessor)
class RNImageProcessor: NSObject {
    let DEFAULT_CANVAS_W: CGFloat = 2480.0
    let DEFAULT_CANVAS_H: CGFloat = 3508.0
    let DEFAULT_CELL_W: CGFloat = 300.0
    let DEFAULT_CELL_H: CGFloat = 300.0
    let DEFAULT_COLUMNS: CGFloat = 5

    var imagesData: [String:Data] = [:]
    
    @objc func createPngImage(_ width: CGFloat, height: CGFloat, fillColor: String, name: String) {
        var imageData: Data?
   
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat()
            renderFormat.scale = 1.0
            let imgRenderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            imageData = imgRenderer.pngData(actions: { context in
                context.cgContext.setFillColor(UIColor(hex: fillColor).cgColor)
                context.cgContext.fill(CGRect(x: 0, y: 0, width: width, height: height))
            })
        } else {
            UIGraphicsBeginImageContext(CGSize(width: width, height: height))
            if let context = UIGraphicsGetCurrentContext() {
                context.setFillColor(UIColor(hex: fillColor).cgColor)
                context.fill(CGRect(x: 0, y: 0, width: width, height: height))
                if let myImage = UIGraphicsGetImageFromCurrentImageContext() {
                    imageData = UIImagePNGRepresentation(myImage)
                }
            }
            
            UIGraphicsEndImageContext()
        }

        if let data = imageData {
            imagesData[name] = data
            saveToGallery("first", format: "png")
        }
    }
    
    @objc func drawImageOnImage(
        _ destImageName: String,
        srcImageName: String,
        destX: CGFloat,
        destY: CGFloat,
        sourceWidth: CGFloat,
        sourceHeight: CGFloat
    ) {
        if let data = imagesData[destImageName], let image = UIImage(data: data) {
            if #available(iOS 10, *) {
                let renderFormat = UIGraphicsImageRendererFormat()
                renderFormat.scale = 1.0
                let imageRenderer = UIGraphicsImageRenderer(size: CGSize(width: image.size.width, height: image.size.height))
                imagesData[destImageName] =  imageRenderer.pngData(actions: { ctx in
                    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                    #imageLiteral(resourceName: "launch_background").draw(in: CGRect(x: 100, y: 100, width: 1000, height: 1000))
                })
            } else {
                 UIGraphicsBeginImageContext(CGSize(width: image.size.width, height: image.size.height))

                 image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                 #imageLiteral(resourceName: "launch_background").draw(in: CGRect(x: 100, y: 100, width: 470, height: 870))
            
                 if let myImage = UIGraphicsGetImageFromCurrentImageContext() {
                     imagesData[destImageName] = UIImagePNGRepresentation(myImage)
                 }
            
                 UIGraphicsEndImageContext()
            }

            saveToGallery(destImageName, format: "png")
        }
    }

    @objc func drawMosaicImage(
        _ imageNames: Array<String>,
        name: String,
        backgroundColor: String,
        options: Dictionary<String, CGFloat>,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        var resultImageData: Data?
        let canvasW = options["canvasWidth"] ?? DEFAULT_CANVAS_W
        let canvasH = options["canvasHeight"] ?? DEFAULT_CANVAS_H
        let columnsCount = options["columnsCount"] ?? DEFAULT_COLUMNS
        let imgCellW = options["imgCellW"] ?? DEFAULT_CELL_W
        let imgCellH = options["imgCellH"] ?? DEFAULT_CELL_H
        let startX = options["startX"] ?? 0
        let startY = options["startY"] ?? 0
        let vertSpace = options["vertSpace"] ?? 0
        let horSpace = options["horSpace"] ?? 0
        let backgroundColor = UIColor(hex: backgroundColor).cgColor

        DispatchQueue.global(qos: .utility).async {
            if #available(iOS 10, *) {
                let renderFormat = UIGraphicsImageRendererFormat()
                renderFormat.scale = 1.0
                let imageRenderer = UIGraphicsImageRenderer(size: CGSize(width: canvasW, height: canvasH), format: renderFormat)

                resultImageData = imageRenderer.pngData(actions: { ctx in
                    ctx.cgContext.setFillColor(backgroundColor)
                    ctx.cgContext.fill(CGRect(x: 0, y: 0, width: canvasW, height: canvasH))
                    for (idx, imageName) in imageNames.enumerated() {
                        let columnIdx = CGFloat(idx % Int(columnsCount))
                        let rowIdx = floor(CGFloat(idx) / columnsCount)
                        let xCoord = startX + (imgCellW * columnIdx) + (horSpace * columnIdx)
                        let yCoord = startY + (imgCellH * rowIdx) + (vertSpace * rowIdx)
                        if let image = UIImage(contentsOfFile: imageName) {
                            image.draw(in: CGRect(x: xCoord, y: yCoord, width: imgCellW, height: imgCellH))
                        }
                    }
                })
            } else {
                UIGraphicsBeginImageContext(CGSize(width: canvasW, height: canvasH))
                if let ctx = UIGraphicsGetCurrentContext() {
                    ctx.setFillColor(backgroundColor)
                    ctx.fill(CGRect(x: 0, y: 0, width: canvasW, height: canvasH))
                }
                
                for (idx, imageName) in imageNames.enumerated() {
                    let columnIdx = CGFloat(idx % Int(columnsCount))
                    let rowIdx = floor(CGFloat(idx) / columnsCount)
                    let xCoord = startX + (imgCellW * columnIdx) + (horSpace * columnIdx)
                    let yCoord = startY + (imgCellH * rowIdx) + (vertSpace * rowIdx)
                    if let image = UIImage(contentsOfFile: imageName) {
                        image.draw(in: CGRect(x: xCoord, y: yCoord, width: imgCellW, height: imgCellH))
                    }
                }

                if let myImage = UIGraphicsGetImageFromCurrentImageContext() {
                    resultImageData = UIImagePNGRepresentation(myImage)
                }
                
                UIGraphicsEndImageContext()
            }
            
            self.imagesData[name] = resultImageData
            resolve(true)
        }
    }
    
    @objc func saveToGallery(_ name: String, format: String) {
        switch (format) {
        case "png":
            if let imageData = imagesData[name], let image = UIImage(data: imageData) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            
        case "jpg":
            // TODO: convert image to jpg
            if let imageData = imagesData[name], let image = UIImage(data: imageData) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }

        default:
            if let imageData = imagesData[name], let image = UIImage(data: imageData) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
        
        imagesData[name] = nil
    }
}
