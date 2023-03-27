//
//  PhotoPreviewVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/27.
//

import UIKit
import Qiniu

class PhotoPreviewVC: EViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    
    var scrollview = UIScrollView()
    var imageView =  UIImageView()
    
    var image: UIImage!
    
    init(_ image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftTitle = "照片预览"
        bottomHeight.constant = 48 + kBottomSpace
        
        scrollview.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 48 - kBottomSpace - kNaviBarHeight)
        view.addSubview(scrollview)
        view.sendSubviewToBack(scrollview)
  

        scrollview.addSubview(imageView)
        imageView.frame = scrollview.frame
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        scrollview.contentSize = image.size
        
        scrollview.delegate = self
        scrollview.maximumZoomScale = 3
        scrollview.minimumZoomScale = 1
        
    }


    
    @IBAction func retakeAction(_ sender: Any) {
        popViewController()
        
        let vc = CamareImportVC(isScaneImport: false)
        vc.modalPresentationStyle = .fullScreen
        AppCommon.getCurrentVC()?.present(vc, animated: true)
    }
    
    
    @IBAction func turnLeft(_ sender: Any) {
        image =  UIImage.rotate(image: image, withAngle: -90)
        imageView.image = image
    }
    
    
    @IBAction func turnRight(_ sender: Any) {
        image = UIImage.rotate(image: image, withAngle: 90)
        imageView.image = image
    }
    
    @IBAction func postAction(_ sender: Any) {
        
        guard var data = image.pngData() else {
            EToast.showFailed("图片解析失败")
            return
        }
        
        EHUD.show("识别中...")
        LoginApi.getOSSConfig { oss in
            if let oss = oss {
                QNUploadManager().put(data, key: oss.key, token: oss.token, complete: { [weak self] info, key, res in
                    if res != nil {
                        self?.cameraScaneRequest(data, imgurl: QNBassUrl + oss.key)
                    }else{
                        EToast.showFailed("头像上传失败")
                    }
                }, option: nil)
            }
        }
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    func cameraScaneRequest(_ data: Data, imgurl: String) {
        FPApi.takePhotoImport(data: data, imgUrl: imgurl) { list in
            
        }
    }
    
}
