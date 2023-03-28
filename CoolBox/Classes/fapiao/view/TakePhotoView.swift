//
//  TakePhotoView.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

private let kMargin: CGFloat = 80
private let screenViewW = UIScreen.main.bounds.width
private let screenViewH =  kScreenHeight - 46 - kStatusBarHeight - 180 - kBottomSpace
private let scanViewWH = 250.0

class TakePhotoView: UIView {
    
    var session = AVCaptureSession()
    var beganTakePicture:Bool = false /// 相机开始拍照
    
    typealias TakePhotoResult = (Image) -> Void
    private var tpResult: TakePhotoResult?
    init( result: TakePhotoResult? = nil, frame: CGRect) {
        super.init(frame: frame)
        tpResult = result
        
        startScan()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        session.stopRunning()
        
    }
    
    func startScan() {
       guard let device = AVCaptureDevice.default(for: .video) else { return }
       do {
           let input = try AVCaptureDeviceInput(device: device)
           //创建输出流
           let output = AVCaptureVideoDataOutput()
           let queue = DispatchQueue(label: "com.brianadvent.captureQueue")
           output.setSampleBufferDelegate(self, queue: queue)

           //初始化链接对象 / 高质量采集率
           session.canSetSessionPreset(.high)
           session.addInput(input)
           session.addOutput(output)

           let layer = AVCaptureVideoPreviewLayer(session: session)
           layer.videoGravity = .resizeAspectFill
           layer.frame = CGRect(x: 0, y: 0, width: screenViewW, height: screenViewH)
           self.layer.insertSublayer(layer, at: 0)
           //开始捕捉
           DispatchQueue.global().async {
               self.session.startRunning()
           }
           let captureConnection = output.connection(with: .video)
            if captureConnection?.isVideoStabilizationSupported == true {
                /// 这个很重要 这个是为了拍照完成，防止图片旋转90度
                captureConnection?.videoOrientation = self.getCaptureVideoOrientation()
            }
       }
       catch {
           print("AVCaptureDeviceInput init error")
       }
   }
    
    /// 旋转方向
    func getCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait,.faceUp,.faceDown:
            return .portrait
        case .portraitUpsideDown: // 如果这里设置成AVCaptureVideoOrientationPortraitUpsideDown,则视频方向和拍摄时的方向是相反的。
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
    
}

extension TakePhotoView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if beganTakePicture == true {
            beganTakePicture = false
            /// 注意在主线程中执行
            DispatchQueue.main.async {
                self.session.stopRunning()
                if let image = self.imageConvert(sampleBuffer: sampleBuffer),
                    let img = UIImage.rotate(image: image, withAngle: -90) {
                    
                    self.tpResult?(img)
                }
          }
      }
    }
}



extension TakePhotoView {
    
    func imageConvert(sampleBuffer:CMSampleBuffer?) -> UIImage? {
          guard sampleBuffer != nil && CMSampleBufferIsValid(sampleBuffer!) == true else { return nil }
          let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer!)
          let ciImage = CIImage(cvPixelBuffer: pixelBuffer!)
        return UIImage(ciImage: ciImage)
      }
}

extension UIImage {
    static func rotate(image: UIImage, withAngle angle: Double) -> UIImage? {

        if angle.truncatingRemainder(dividingBy: 360) == 0 { return image }

        let imageRect = CGRect(origin: .zero, size: image.size)

        let radian = CGFloat(angle / 180 * M_PI)

        let rotatedTransform = CGAffineTransform.identity.rotated(by: radian)

        var rotatedRect = imageRect.applying(rotatedTransform)

        rotatedRect.origin.x = 0

        rotatedRect.origin.y = 0

        UIGraphicsBeginImageContext(rotatedRect.size)

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.translateBy(x: rotatedRect.width / 2, y: rotatedRect.height / 2)

        context.rotate(by: radian)

        context.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)

        image.draw(at: .zero)

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return rotatedImage

    }
    
    
    static func fixOrientation(image : UIImage) -> UIImage {
   
        var transform = CGAffineTransform.identity
        switch image.imageOrientation {
        case .down,.downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case .left,.leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))

        case .right,.rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
       
        default:
            break
        }
        
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        
        let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue)
        ctx!.concatenate(transform)
        switch image.imageOrientation {
        case .left,.leftMirrored,.rightMirrored,.right:
            ctx?.draw(image.cgImage!, in: CGRect(x :0,y:0,width:image.size.height,height: image.size.width))
            
        default:
             ctx?.draw(image.cgImage!, in: CGRect(x :0,y:0,width:image.size.width,height: image.size.height))
        }
        let cgimg = ctx!.makeImage()
        let img = UIImage(cgImage: cgimg!)
        return img
    }
}
