//
//  QRGeneratorTool.swift
//  huandian
//
//  Created by jhin on 2020/12/11.
//  Copyright © 2020 immptor. All rights reserved.
//

import UIKit

public struct QRGeneratorTool {
    
    static func generateQRCodeImage(_ content: String, size: CGSize) -> UIImage?
    {
        // 创建滤镜
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {return nil}
        // 还原滤镜的默认属性
        filter.setDefaults()
        // 设置需要生成的二维码数据
        let contentData = content.data(using: String.Encoding.utf8)
        filter.setValue(contentData, forKey: "inputMessage")

        // 从滤镜中取出生成的图片
        guard let ciImage = filter.outputImage else {return nil}

        let context = CIContext(options: nil)
        let bitmapImage = context.createCGImage(ciImage, from: ciImage.extent)

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)

        //draw image
        let scale = min(size.width / ciImage.extent.width, size.height / ciImage.extent.height)
        bitmapContext!.interpolationQuality = CGInterpolationQuality.none
        bitmapContext?.scaleBy(x: scale, y: scale)
        bitmapContext?.draw(bitmapImage!, in: ciImage.extent)

        //保存bitmap到图片
        guard let scaledImage = bitmapContext?.makeImage() else {return nil}

        return UIImage(cgImage: scaledImage)
    }
}

