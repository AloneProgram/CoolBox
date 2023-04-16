//
//  CamareImportVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit
import TZImagePickerController

class CamareImportVC: EViewController, PresentToCenter {
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var camareView: UIView!
    
    @IBOutlet weak var leftBtn: UIButton!
    
    @IBOutlet weak var rightBtn: UIButton!
    
    @IBOutlet weak var middleBtn: UIButton!
        
    @IBOutlet weak var takePhotoBtn: UIButton!
    
    var takePhotoView: TakePhotoView?
    
    var scaneView: ScaneVIew?
    
    var isScaneImport: Bool = true {
        didSet {
            if camareView != nil {
                isScaneImport ? changeToScaneView() : changeToTakePhotoView()
            }
        }
    }
    
    init(isScaneImport: Bool) {
        self.isScaneImport = isScaneImport
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        isScaneImport ? changeToScaneView() : changeToTakePhotoView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if self.isScaneImport {
                let hasShow = UserDefaults.standard.bool(forKey: "HasShowScaneTipsAlert")
                if !hasShow {
                    let alert = ScaneTipsAlert()
                    self.presentToCenter(alert)
                }
            }else {
                let hasShow = UserDefaults.standard.bool(forKey: "HasShowTpTipsAlert")
                if !hasShow {
                    let alert = tpTipsAlert()
                    self.presentToCenter(alert)
                }
            }
        }
    }
    
    func changeToTakePhotoView() {
        dismissBtn.setTitle("拍照导入", for: .normal)
        scaneView?.removeFromSuperview()
        scaneView = nil
        
        leftBtn.isHidden = false
        rightBtn.isHidden = true
        middleBtn.setTitle("拍照导入", for: .normal)
        takePhotoBtn.isHidden = false
        
        
        let handleResult: ((Image) -> Void) = {[weak self] img in
            self?.toPhotoPreview(image: img)
        }
        
        takePhotoView = TakePhotoView(result: handleResult, frame: CGRect(x: 0, y: 46 + kNaviBarHeight, width: kScreenWidth, height: kScreenHeight - (46 + kNaviBarHeight) - 180 - kBottomSpace ))
        camareView.addSubview(takePhotoView!)
        takePhotoView!.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func changeToScaneView() {
        dismissBtn.setTitle("扫码导入", for: .normal)
        takePhotoView?.removeFromSuperview()
        takePhotoView = nil
        
        leftBtn.isHidden = true
        rightBtn.isHidden = false
        middleBtn.setTitle("扫码导入", for: .normal)
        takePhotoBtn.isHidden = true
        
        let handleResult: ((String) -> Void) = { [weak self] result in
            self?.handleResult(result)
        }
        
        scaneView = ScaneVIew(result: handleResult,frame: CGRect(x: 0, y: 46 + kNaviBarHeight, width: kScreenWidth, height: kScreenHeight - (46 + kNaviBarHeight) - 180 - kBottomSpace))
        camareView.addSubview(scaneView!)
        scaneView!.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    @IBAction func takePhotoAction(_ sender: Any) {
        takePhotoView?.beganTakePicture = true
    }
    
    
    @IBAction func albumAction(_ sender: Any) {
        // 相册
        func doit() {
            guard let imagePicker = TZImagePickerController(maxImagesCount: 1, delegate: self) else { return }
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.allowPickingVideo = false
            present(imagePicker, animated: true, completion: nil)
        }
        SystemHelper.verifyPhotoLibraryAuthorization({ doit() })
    }
    
    
    @IBAction func leftAction(_ sender: Any) {
        changeToScaneView()
    }
    
    @IBAction func rightAction(_ sender: Any) {
        changeToTakePhotoView()
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    func handleResult(_ result: String) {
        scanImportrequest(result)
    }
    
    func scanImportrequest(_ qrCode: String){
        FPApi.scanImport(qeCodeStr: qrCode) { [weak self]success in
            if success {
                NotificationCenter.default.post(name: Notification.Name("ImportFPSuccess"), object: nil)
                self?.dismiss(animated: true)
            }
        }
    }
    
    func toPhotoPreview(image: UIImage) {
        dismiss(animated: true)
        let _ = delay(0.5) {
            AppCommon.getCurrentVC()?.push(PhotoPreviewVC(image))
        }
    }
        
}

extension CamareImportVC: TZImagePickerControllerDelegate{
    func imagePickerController(_ picker: TZImagePickerController!, didSelect asset: PHAsset!, photo: UIImage!, isSelectOriginalPhoto: Bool) {
        toPhotoPreview(image: photo)
    }
}
