//
//  ImageDownloader.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit
import Kingfisher

struct ImageDownloader {
    
    static func loadData(url: URL, maxKByte: Int = 0, result: @escaping (Data?) -> Void) {
        downImage(url: url) { (image) in
            guard let image = image else { result(nil); return }
            compressObjImageQuality(image, toKByte: maxKByte, result: result)
        }
    }
    
    static func load(url: URL, maxKByte: Int = 0, result: @escaping (UIImage?) -> Void) {
        downImage(url: url) { (image) in
            guard let image = image else { result(nil); return }
            compressObjImageQuality(image, toKByte: maxKByte, result: result)
        }
    }
    
    private static func downImage(url: URL, result: @escaping (UIImage?) -> Void) {
        let kfManager = KingfisherManager.shared
        let cache = kfManager.cache
        let optionsInfo: KingfisherOptionsInfo = KingfisherManager.shared.defaultOptions + [.targetCache(cache), .backgroundDecode]
        let resource = ImageResource(downloadURL: url)
        
        // 先使用缓存，没有缓存再去下载
        kfManager.retrieveImage(with: resource,
                                options: optionsInfo,
                                progressBlock: nil) { (res) in
                                    switch res {
                                    case .success(let value): result(value.image)
                                    case .failure(_): result(nil)
                                    }
        }
    }
    
    //修改图片质量
    static func compressImageQuality(_ image: UIImage, toKByte maxLengthKb: Int, result: @escaping (Data?) -> Void) {
        DispatchQueue.global().async {
            let maxLength = maxLengthKb * 1000
            self.compressImageQuality(image, maxLength: maxLength) { (data) in
                result(data)
            }
        }
    }
}

extension ImageDownloader {
    
    static func compressObjImageQuality(_ image: UIImage, toKByte maxLengthKb: Int, result: @escaping (_ image: UIImage?) -> Void) {
        guard maxLengthKb > 0 else { result(image); return }
        let maxLength = maxLengthKb * 1000
        self.compressImageQuality(image, maxLength: maxLength) { (data) in
            if let data = data, let image = UIImage(data: data) {
                result(image)
            }
            else {
                result(nil)
            }
        }
    }
    
    static func compressObjImageQuality(_ image: UIImage, toKByte maxLengthKb: Int, result: ((_ data: Data?) -> Void)?) {
        let maxLength = maxLengthKb * 1000
        compressImageQuality(image, maxLength: maxLength, result: result)
    }
    
    static func compressImageQuality(_ image: UIImage, maxLength: Int, result: ((_ data: Data?) -> Void)?) {
        var compression: CGFloat = 1.0
        guard var data = image.jpegData(compressionQuality: compression) else {
            result?(nil); return
        }
        if data.count < maxLength {
            result?(data)
            return
        }
        
        // 二分法压缩
        var max: CGFloat = 1.0
        var min: CGFloat = 0.0
        for _ in 0...5 {
            compression = (max + min) / 2.0
            if let temp = image.jpegData(compressionQuality: compression) {
                data = temp
            }
            else { break }
            if data.count < Int(Double(maxLength) * 0.9) {
                min = compression
            }
            else if data.count > maxLength {
                max = compression
            }
            else { break }
        }
        
        if data.count < maxLength {
            result?(data)
            return
        }
        // 重新绘制新图 压缩size
        var lastDataLength = 0
        if var resultImage = UIImage(data: data) {
            while data.count > maxLength && data.count != lastDataLength {
                lastDataLength = data.count
                let ratio = Float(maxLength) / Float(data.count)
                // Int 防止白边
                let size = CGSize(width: CGFloat(Int(Float(resultImage.size.width) * sqrtf(ratio))),
                                  height: CGFloat(Int(Float(resultImage.size.height) * sqrtf(ratio))))
                UIGraphicsBeginImageContext(size)
                resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                if let image = UIGraphicsGetImageFromCurrentImageContext() {
                    resultImage = image
                }
                UIGraphicsEndImageContext()
                if let temp = resultImage.jpegData(compressionQuality: compression) {
                    data = temp
                }
                else  { break }
            }
        }
        result?(data)
    }
}


extension UIImageView {
    //播放本地gif
    func setLocalGif(_ path: String?) {
        guard let path = path else { return }
        let url = URL(fileURLWithPath: path)
        let provider = LocalFileImageDataProvider(fileURL: url)
        self.kf.setImage(with: provider)
    }
}
