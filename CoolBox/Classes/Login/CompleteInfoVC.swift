//
//  CompleteInfoVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/16.
//

import UIKit

class CompleteInfoVC: EViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(setAvatar))
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
    }
    
    @IBAction func skipAction(_ sender: Any) {
        let keyWindow = UIApplication.shared.delegate?.window
        keyWindow??.rootViewController = AppTabBarController()
    }
    
    @objc func setAvatar() {
        
        let alert = SelectAlert()
        let cancel = SelectAlertAction(title: "取消", type: .cancel)
        let takePhoto  = SelectAlertAction(title: "拍照") { [weak self] in
            self?.takePhoto()
        }
        let selectPhoto  = SelectAlertAction(title: "从手机相册选择") { [weak self] in
            self?.selectPhoto()
        }
        
        alert.addAction(takePhoto)
        alert.addAction(selectPhoto)
        alert.addAction(cancel)
        alert.show()
    }
    
    
    func takePhoto() {
        // 拍照
        func doit() {
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .camera
            imagePickerVC.delegate = self
            present(imagePickerVC, animated: true, completion: nil)
        }
        SystemHelper.verifyCameraAuthorization({ doit() })
    }
    
    func selectPhoto() {
        // 相册
        func doit() {
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.delegate = self
            present(imagePickerVC, animated: true, completion: nil)
        }
        
        SystemHelper.verifyPhotoLibraryAuthorization({ doit() })
    }
    
    func uploadImage(_ image: UIImage) {
        
        ImageDownloader.compressImageQuality(image, toKByte: 5 * 1024) { data in
            guard let data = data else { return }
            DispatchQueue.main.async {
                EHUD.dismiss()
//                PersonalApi.uploadFile(data) { [weak self] (url) in
//                    PersonalApi.uploadInfo(headUrl: url) { (success) in
//                        self?.stopLoading()
//                        if success {
//                            self?.avatar.image = image
//                            let account = Login.currentAccount()
//                            account.headUrl = url
//                            Login.update(account: account)
//                            EToast.showSuccess("头像修改成功")
//                        }else {
//                            EToast.showFailed("头像修改失败")
//                        }
//                    }
//                }
            }
        }
    }
}

extension CompleteInfoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false, completion: nil)
        let image = info[.originalImage] as! UIImage
        let cropperImage = RImageCropperViewController(originalImage: image, cropFrame: CGRect.init(x: (kScreenWidth - 300)/2, y: (kScreenHeight - 300)/2, width: 300, height: 300), limitScaleRatio: 30)
        cropperImage.delegate = self
        push(cropperImage)
    }
    
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension CompleteInfoVC : RImageCropperDelegate {
    func imageCropper(cropperViewController: RImageCropperViewController, didFinished editImg: UIImage) {
        EHUD.show()
        uploadImage(editImg)
        cropperViewController.navigationController?.popViewController(animated: false)
    }
    
    func imageCropperDidCancel(cropperViewController: RImageCropperViewController) {
        cropperViewController.navigationController?.popViewController(animated: false)
    }
}

