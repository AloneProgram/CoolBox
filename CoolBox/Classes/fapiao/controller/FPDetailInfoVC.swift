//
//  FPDetailInfoVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/2.
//

import UIKit
import Qiniu
import JXPhotoBrowser

class FPDetailInfoVC: EViewController {
    
    @IBOutlet weak var fapiaoImageView: UIImageView!
    
    @IBOutlet weak var impotBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bttomViewHeight: NSLayoutConstraint!
    
    
    private var bottomActionView: BottomActionView!
    
    private var list: [[Any]] = []
    
    private var detailModel: FapiaoDetailModel?
    
    private var invoiceId = ""
    
    init(_ invoiceId: String) {
        self.invoiceId = invoiceId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestDetail()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftTitle = "发票详情"
        
        bttomViewHeight.constant = 48 + kBottomSpace
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.backgroundColor = .clear
       
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "CommonInfoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommonInfoCell")
        tableView.estimatedRowHeight = 54
        tableView.separatorStyle = .none
        
    }


    @IBAction func tapImageAction(_ sender: Any) {
        if detailModel?.fileUrl.length ?? 0 == 0  {
            //选择发票图片
            // 相册
            func doit() {
                guard let imagePicker = TZImagePickerController(maxImagesCount: 1, delegate: self) else { return }
                imagePicker.modalPresentationStyle = .fullScreen
                imagePicker.allowPickingVideo = false
                imagePicker.allowTakePicture = false
                present(imagePicker, animated: true, completion: nil)
            }
            SystemHelper.verifyPhotoLibraryAuthorization({ doit() })
        }else{
            //预览发票图片
            let browser = JXPhotoBrowser()
            browser.numberOfItems = {
                return 1
            }
            browser.reloadCellAtIndex = {[weak self] context in
                let browserCell = context.cell as? JXPhotoBrowserImageCell
                if let url = self?.detailModel?.fileUrl {
                    browserCell?.imageView.kf.setImage(with: URL(string: url))
                }
            }
            browser.pageIndicator = JXPhotoBrowserNumberPageIndicator()
            browser.pageIndex = 0
            browser.show()
        }
    }
    
    
    func updateBottomActionView() {
        if detailModel?.status == "1" || detailModel?.status == "3" {
            bottomView.isHidden = true
            return
        }
        bottomView.isHidden = false
        bottomView.subviews.forEach({$0.removeFromSuperview()})
        
        
        var btootomActionType: BottomActionType = .fp_normal
        if detailModel?.status == "5" { //无需报销
            btootomActionType = .fp_unNeed
        }
                
        bottomActionView =  BottomActionView(type: btootomActionType, frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 48))
        bottomActionView.actionBlock = { [weak self] tag in
            switch tag {
            case 0:
                self?.deleteFP()
            case 1:
                self?.unbaleBX()
            case 2:
                self?.createBX()
            default:
                break
            }
        }
        bottomView.addSubview(bottomActionView)
    }
    
    func requestDetail() {
        
        FPApi.fapioaInfo(id: invoiceId) {[weak self] detail in
            self?.list = []
            self?.detailModel = detail
            
            self?.list.append(detail.template.filter({$0.show == "1"}))
            
            if detail.status != "1", detail.status != "3" {
                self?.list.append([CommonInfoModel(leftText: "完整发票信息", rightText: "修改", showRightArrow: true)])
            }
            
            self?.tableView.reloadData()
            self?.fapiaoImageView.kf.setImage(with: URL(string: detail.fileUrl), placeholder: UIImage(named: "import_fapiaoBg"))
            self?.impotBtn.isHidden = detail.fileUrl.length > 0
            
            self?.updateBottomActionView()
        }
    }
    
    func deleteFP() {
        let alert = SelectAlert(alertTitle: "确定删除这张发票吗")
        let cancel = SelectAlertAction(title: "取消", type: .cancel)

        let deleteFP = SelectAlertAction(title: "删除", titleColor: UIColor(hexString: "#F53F3F")) { [weak self] in
            self?.deleteFPRequest()
        }
        
        alert.addAction(deleteFP)
        alert.addAction(cancel)
        alert.show()
    }
    
    func unbaleBX() {
        FPApi.setFPStatus(idsStr: invoiceId) { [weak self] _ in
            self?.requestDetail()
        }
    }
    
    func createBX() {
        let alert = SelectAlert(alertTitle: "选择报销类型")
        let cancel = SelectAlertAction(title: "取消", type: .cancel)

        let travleBX = SelectAlertAction(title: "差旅费报销") { [weak self] in
            self?.removeCurrentAndPush(viewController: BXEditInfoVC("1", ids: self?.invoiceId ?? "") )
        }
        let feeBX = SelectAlertAction(title: "费用报销") { [weak self] in
            self?.removeCurrentAndPush(viewController: BXEditInfoVC("2", ids: self?.invoiceId ?? "") )
        }
        
        alert.addAction(travleBX)
        alert.addAction(feeBX)
        alert.addAction(cancel)
        alert.show()
        
    }
    
    func deleteFPRequest() {

        FPApi.deleteFP(idsStr: invoiceId) {[weak self] _ in
            self?.popViewController()
        }
    }
    
    func uploadimage(_ image: UIImage) {
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
                                self?.setFPimage(QNBassUrl + oss.key)
                            }else{
                                EToast.showFailed("发票图片上传失败")
                            }
                        }, option: nil)
                    }
                }
                
            }
        }
    }
    
    func setFPimage(_ url: String) {
        FPApi.setFPFile(id: invoiceId, fileUrl: url) { [weak self] suceess in
            if suceess {
                self?.requestDetail()
            }
        }
    }
}

extension FPDetailInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommonInfoCell = tableView.dequeueReusableCell(withIdentifier: "CommonInfoCell", for: indexPath) as! CommonInfoCell
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            cell.bindTemplate(list[0][indexPath.row] as! Template)
        }else {
            cell.bindData(list[1][indexPath.row] as! CommonInfoModel)
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            push(FPEditInfoVC(invoiceId))
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.01
    }
}

extension FPDetailInfoVC: TZImagePickerControllerDelegate{
    func imagePickerController(_ picker: TZImagePickerController!, didSelect asset: PHAsset!, photo: UIImage!, isSelectOriginalPhoto: Bool) {
        EHUD.show("正在上传")
        uploadimage(photo)
        
    }
}
