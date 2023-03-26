//
//  ScaneVIew.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

private let kMargin: CGFloat = 80
private let screenViewW = UIScreen.main.bounds.width
private let screenViewH =  kScreenHeight - 46 - kStatusBarHeight - 180 - kBottomSpace
private let scanViewWH = 250.0

class ScaneVIew: UIView {

    private var scanView = UIView()
    private var session = AVCaptureSession()
    
    typealias ScanResult = (String) -> Void
    private var scanResult: ScanResult?
    init( result: ScanResult? = nil, frame: CGRect) {
        super.init(frame: frame)
        scanResult = result
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        session.stopRunning()
    }
    
    func setupSubviews() {
        backgroundColor = .black
        setupMaskView()
        setupScanView()
        
        startScan()
    }
    
    func setupMaskView() {
        let rect =  CGRect(x: 0, y: 0, width: screenViewW, height: screenViewH)
        let maskView = UIView(frame: rect)

        //背景
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        
        let holeRect = CGRect(x: (kScreenWidth - scanViewWH)/2,
                              y: 150,
                              width: scanViewWH,
                              height: scanViewWH)
        
        //镂空
        let holePath = UIBezierPath(rect: holeRect)
        path.append(holePath)
        path.usesEvenOddFillRule = true
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillRule = .evenOdd
        layer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        layer.opacity = 1
        
        maskView.layer.addSublayer(layer)
        
        addSubview(maskView)
        clipsToBounds = true
    }
    
    func setupScanView() {
        
        scanView.frame = CGRect(x: (kScreenWidth - scanViewWH)/2,
                                y: 150,
                                width: scanViewWH,
                                height: scanViewWH)
        scanView.backgroundColor = UIColor.clear
        scanView.borderColor = UIColor.white.withAlphaComponent(0.3)
        scanView.borderWidth = 0.5
        scanView.clipsToBounds = true
        addSubview(scanView)
        
        let borderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: scanViewWH, height: scanViewWH))
        borderImageView.image = UIImage(named: "icon_scan_border")
        scanView.addSubview(borderImageView)
        
    }
    
    
    func startScan() {
       guard let device = AVCaptureDevice.default(for: .video) else { return }
       do {
           let input = try AVCaptureDeviceInput(device: device)
           //创建输出流
           let output = AVCaptureMetadataOutput()
           output.rectOfInterest = CGRect(x: 0.1, y: 0, width: 0.9, height: 1)
           //设置代理,在主线程刷新
           output.setMetadataObjectsDelegate(self, queue: .main)
           //初始化链接对象 / 高质量采集率
           session.canSetSessionPreset(.high)
           session.addInput(input)
           session.addOutput(output)

           //在上面三行之后写下面代码,不然报错如下:
           //Terminating app due to uncaught exception 'NSInvalidArgumentException',
           //reason: '*** -[AVCaptureMetadataOutput setMetadataObjectTypes:] Unsupported type found - use -availableMetadataObjectTypes'
           //http://stackoverflow.com/questions/31063846/avcapturemetadataoutput-setmetadataobjecttypes-unsupported-type-found
           
           //设置扫码支持的编码格式
           output.metadataObjectTypes = [.qr, .ean8, .ean13, .code128]
           
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

extension ScaneVIew: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }
        
        if object.type == .qr, let result = object.stringValue {
            session.stopRunning()
            scanResult?(result)
        }
    }
}
