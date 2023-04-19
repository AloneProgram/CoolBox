//
//  AccountInfoVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/18.
//

import UIKit
import Qiniu
@_exported import TZImagePickerController

class AccountInfoVC: EViewController, PresentToCenter {
    
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "CommonInfoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommonInfoCell")
        tableView.estimatedRowHeight = 54
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private var list: [[CommonInfoModel]] = [
        [
            CommonInfoModel(leftText: "姓名", rightText: Login.currentAccount().nickname, showRightArrow: true),
            CommonInfoModel(leftText: "头像", showRightArrow: true, showRightImageView: true, rightImageUrl: Login.currentAccount().avatarUrl)
        ],
        [
            CommonInfoModel( leftText: "手机号码", rightText: Login.currentAccount().mobile, showRightArrow: true),
        ],
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EColor.viewBgColor
        leftTitle = "账号与安全"
        tableView.backgroundColor = EColor.viewBgColor
        view.addSubview(tableView)
        view.sendSubviewToBack(tableView)
        tableView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(-100)
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        LoginApi.logout { success in
            if success {
                Login.logout()
                let keyWindow = UIApplication.shared.delegate?.window
                keyWindow??.rootViewController = LoginVC()
            }
        }
    }
    
    
    @IBAction func deleteAccount(_ sender: Any) {
        let alert = DeleteAccountAlert(cancle:  { [weak self] in
            self?.deleteAccount()
        })
        presentToCenter(alert)
    }
    
}

// MARK: Action
extension AccountInfoVC {
    func editNickname() {
        let alert = SingelInputAlert(title: "请输入姓名", placeText: Login.currentAccount().nickname, confirm:  { [weak self] text in
            if let nick = text {
                self?.editNick(nick)
            }else {
                EToast.showFailed("昵称不可为空")
            }
        })
        presentToCenter(alert)
        
    }
    
    func changeMobile() {
        let alert = TwoInputAlert(confirm: { [weak self] phone, code in
            self?.changeMobile(phone: phone, code: code)
        })
        presentToCenter(alert)
    }
    
    func editAvatar() {
        let alert = SelectAlert(alertTitle: "上传头像")
        let cancel = SelectAlertAction(title: "取消", type: .cancel)
        let takePhoto = SelectAlertAction(title: "拍照上传") { [weak self] in
            self?.takePhoto()
        }
        let selectPhoto = SelectAlertAction(title: "相册上传") { [weak self] in
            self?.selectPhoto()
        }
        
        alert.addAction(selectPhoto)
        alert.addAction(takePhoto)
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
            guard let imagePicker = TZImagePickerController(maxImagesCount: 1, delegate: self) else { return }
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.allowPickingVideo = false
            imagePicker.allowTakePicture = false
            present(imagePicker, animated: true, completion: nil)
        }
        SystemHelper.verifyPhotoLibraryAuthorization({ doit() })
    }
    
   
}

// MARK: Request
extension AccountInfoVC {
    func editNick(_ nick: String) {
        MineApi.updateUserInfo(params: ["nickname": nick]) { [weak self] in
            self?.list[0][0].rightText = nick
            self?.tableView.reloadData()
        }
        
    }
    
    func uploadImage(_ image: UIImage) {
        
        ImageDownloader.compressImageQuality(image, toKByte: 5 * 1024) { data in
            guard let data = data else {
                EHUD.dismiss()
                return
                
            }
            DispatchQueue.main.async {
                EHUD.dismiss()
                LoginApi.getOSSConfig { oss in
                    if let oss = oss {
                        QNUploadManager().put(data, key: oss.key, token: oss.token, complete: { [weak self] info, key, res in
                            if res != nil {
                                self?.uploadAvatar(QNBassUrl + oss.key)
                            }else{
                                EToast.showFailed("头像上传失败")
                            }
                        }, option: nil)
                    }
                }
                
            }
        }
    }
    
    func uploadAvatar(_ avatar: String) {
        MineApi.updateUserInfo(params: ["avatar_url": avatar]) { [weak self] in
            self?.list[0][1].rightImageUrl = avatar
            self?.tableView.reloadData()
        }
    }
    
    func changeMobile(phone: String, code: String) {
        MineApi.changeMobile(phone: phone, vCode: code) {[weak self] in
            self?.list[1][0].rightText = phone
            self?.tableView.reloadData()
        }
    }
    
    func deleteAccount() {
        MineApi.deleteAccount { [weak self] success in
            if success {
                Login.logout()
                let keyWindow = UIApplication.shared.delegate?.window
                keyWindow??.rootViewController = LoginVC()
            }
        }
    }
    
}

extension AccountInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommonInfoCell = tableView.dequeueReusableCell(withIdentifier: "CommonInfoCell", for: indexPath) as! CommonInfoCell
        cell.selectionStyle = .none
        cell.bindData(list[indexPath.section][indexPath.row])
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                editNickname()
            }else {
                editAvatar()
            }
        case 1:
            changeMobile()
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36))
        let lab = UILabel(text: section == 0 ? "账号信息" : "安全信息", font: SCFont(14), nColor: UIColor(hexString: "#939AA3"))
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.01
    }
}

extension AccountInfoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension AccountInfoVC: TZImagePickerControllerDelegate{
    func imagePickerController(_ picker: TZImagePickerController!, didSelect asset: PHAsset!, photo: UIImage!, isSelectOriginalPhoto: Bool) {
        let cropperImage = RImageCropperViewController(originalImage: photo, cropFrame: CGRect.init(x: (kScreenWidth - 300)/2, y: (kScreenHeight - 300)/2, width: 300, height: 300), limitScaleRatio: 30)
        cropperImage.delegate = self
        push(cropperImage)
    }
}

extension AccountInfoVC : RImageCropperDelegate {
    func imageCropper(cropperViewController: RImageCropperViewController, didFinished editImg: UIImage) {
        EHUD.show("正在上传")
        uploadImage(editImg)
        cropperViewController.navigationController?.popViewController(animated: false)
    }
    
    func imageCropperDidCancel(cropperViewController: RImageCropperViewController) {
        cropperViewController.navigationController?.popViewController(animated: false)
    }
}
