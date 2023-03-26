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
       }
       catch {
           print("AVCaptureDeviceInput init error")
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
                if let image = self.imageConvert(sampleBuffer: sampleBuffer) {
                    self.tpResult?(image)
                }
          }
      }
    }
}



extension TakePhotoView {
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
    
    func imageConvert(sampleBuffer:CMSampleBuffer?) -> UIImage? {
          guard sampleBuffer != nil && CMSampleBufferIsValid(sampleBuffer!) == true else { return nil }
          let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer!)
          let ciImage = CIImage(cvPixelBuffer: pixelBuffer!)
          return UIImage(ciImage: ciImage)
      }
}
