//
//  QRScanViewController.swift
//  Livepush
//
//  Created by winter on 2020/4/17.
//  Copyright © 2020 yeting. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

private let kMargin: CGFloat = 80
private let screenViewW = UIScreen.main.bounds.width
private let screenViewH = UIScreen.main.bounds.height
private let scanViewWH = 250.0

class QRScanViewController: EViewController {
    
    override var navigationBarStyle: NavigationBarStyle { return .transparentBackground}
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private var scanView = UIView()
    private var session = AVCaptureSession()
    
    typealias ScanResult = () -> Void
    private var scanResult: ScanResult?
    init( result: ScanResult? = nil) {
        scanResult = result
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        startScan()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - method
fileprivate extension QRScanViewController {
    
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
            layer.frame = view.layer.bounds
            view.layer.insertSublayer(layer, at: 0)
            //开始捕捉
            DispatchQueue.global().async {
                self.session.startRunning()
            }
        }
        catch {
            print("AVCaptureDeviceInput init error")
        }
    }

    
    func scanQRCode(_ code: String) {
        MineApi.scaneLogin(token: code) { [weak self] in
            self?.popViewController()
        }
    }
}

extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }
        
        if object.type == .qr, let result = object.stringValue {
            session.stopRunning()
            scanQRCode(result)
        }
    }
}

// MARK: - UI
fileprivate extension QRScanViewController {
    
    func setupSubviews() {
        view.backgroundColor = .black
        setupMaskView()
        setupScanView()
    }
    
    func setupMaskView() {
        let rect =  CGRect(x: 0, y: 0, width: screenViewW, height: screenViewH)
        let maskView = UIView(frame: rect)

        //背景
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        
        let holeRect = CGRect(x: (kScreenWidth - scanViewWH)/2,
                              y: 125 + kNaviBarHeight,
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
        
        view.addSubview(maskView)
        view.clipsToBounds = true
    }
    
    func setupScanView() {
        
        scanView.frame = CGRect(x: (kScreenWidth - scanViewWH)/2,
                                y: 125 + kNaviBarHeight,
                                width: scanViewWH,
                                height: scanViewWH)
        scanView.backgroundColor = UIColor.clear
        scanView.borderColor = UIColor.white.withAlphaComponent(0.3)
        scanView.borderWidth = 0.5
        scanView.clipsToBounds = true
        view.addSubview(scanView)
        
        
        let borderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: scanViewWH, height: scanViewWH))
        borderImageView.image = UIImage(named: "icon_scan_border")
        scanView.addSubview(borderImageView)
        
        let tipsLab = UILabel()
        tipsLab.numberOfLines = 2
        tipsLab.text = "将取景框对准二维码/条码，\n即可自动扫描"
        tipsLab.font = SCFont(13)
        tipsLab.textAlignment = .center
        tipsLab.textColor = .white
        tipsLab.alpha = 0.6
        view.addSubview(tipsLab)
        tipsLab.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(scanView.snp.bottom).offset(20)
        }
    }
}
