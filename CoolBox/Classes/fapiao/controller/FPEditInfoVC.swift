//
//  FPEditInfoVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/2.
//

import UIKit
import Qiniu
import JXPhotoBrowser

class FPEditInfoVC: EViewController, PresentFromBottom {
    
    @IBOutlet weak var fapiaoImageView: UIImageView!
    
    @IBOutlet weak var impotBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bttomViewHeight: NSLayoutConstraint!
    
    private var detailModel: FapiaoDetailModel?
    
    private var invoiceId = ""
    
    var list: [[Template]] = []
    var hiddenBottom = false
    
    init(_ invoiceId: String, hiddenBottom: Bool = false) {
        self.invoiceId = invoiceId
        self.hiddenBottom = hiddenBottom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        leftTitle = hiddenBottom ? "发票信息" : "编辑发票信息"
        
        view.backgroundColor = EColor.viewBgColor
        tableView.backgroundColor = .clear
        
        bottomView.isHidden = hiddenBottom
        if hiddenBottom {
            bttomViewHeight.constant = 0
        }else {
            bttomViewHeight.constant = 48 + kBottomSpace
        }
                
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "CommonInputCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommonInputCell")
        tableView.estimatedRowHeight = 56
        tableView.separatorStyle = .none
        
        requestDetail()
    }
    
    func requestDetail() {
        FPApi.fapioaInfo(id: invoiceId) {[weak self] detail in
            self?.list = []
            self?.detailModel = detail
            
            detail.template.filter({$0.edit == "1"}).forEach { t in
                self?.list.append([t])
            }
            
            self?.tableView.reloadData()
            self?.fapiaoImageView.kf.setImage(with: URL(string: detail.fileUrl), placeholder: UIImage(named: "import_fapiaoBg"))
            self?.impotBtn.isHidden = detail.fileUrl.length > 0
        }
    }
    
    @IBAction func tapFileAction(_ sender: Any) {
        if detailModel?.fileUrl.length ?? 0 == 0  {
            //选择发票图片
            // 相册
            func doit() {
                guard let imagePicker = TZImagePickerController(maxImagesCount: 1, delegate: self) else { return }
                imagePicker.modalPresentationStyle = .fullScreen
                imagePicker.allowPickingVideo = false
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
    
    
    @IBAction func saveAction(_ sender: Any) {
        var params: [String: String] = [:]
        list.forEach { list in
            guard let t = list.first else { return }
            if t.field == "item_type" {
                params[t.field] = GlobalConfigManager.getKey(with: t.value, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceItemType)
            }else  if t.field == "type" {
                params[t.field] = GlobalConfigManager.getKey(with: t.value, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceType)
            }else  if t.field == "cat_id" {
                params[t.field] = GlobalConfigManager.getKey(with: t.value, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceCatId)
            }else {
                params[t.field] = t.value
            }
        }
        
        params["invoice_id"] = invoiceId
                
        FPApi.saveInfo(params: params) { [weak self]_ in
            self?.popViewController()
        }
    }
    
    func editInputInfo(_ text: String, indexPath: IndexPath) {
        var t = list[indexPath.section][indexPath.row]
        t.value = text
        list[indexPath.section][indexPath.row] = t
        tableView.reloadData()
    }
    
    func uploadimage(_ image: UIImage) {
        ImageDownloader.compressImageQuality(image, toKByte: 5 * 1024) { data in
            guard let data = data else { return }
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

extension FPEditInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommonInputCell = tableView.dequeueReusableCell(withIdentifier: "CommonInputCell", for: indexPath) as! CommonInputCell
        cell.selectionStyle = .none
        cell.bindTemplet(t: list[indexPath.section][indexPath.row])

        cell.textEndEditBlock = {  [weak self] text in
            self?.editInputInfo(text, indexPath: indexPath)
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let t = list[indexPath.section][indexPath.row]
        if t.type == "datetime" { //日期选择
            let result: DatePicker.DatePickerClosure = { [weak self] dateStr in
                var tmp = t
                tmp.value = dateStr
                self?.list[indexPath.section][indexPath.row] = tmp
                tableView.reloadData()
            }
            let picker = DatePicker(.date, handle: result)
            presentFromBottom(picker)
        }else if t.type == "select" { //属性选择
            guard let config = GlobalConfigManager.shared.systemoInfoConfig else { return}
            
            var values: [String] = []
            if t.field == "item_type" {
                values = config.invoidceItemType_values
            }else  if t.field == "type" {
                values = config.invoidceType_values
            }else  if t.field == "cat_id" {
                values = config.invoidceCatId_values
            }
            
            var tmp: [[String]] = []
            values.forEach { v in
                tmp.append([v])
            }
            let picker = McPicker(data: [tmp])
            picker.fontSize = 16
            picker.toolbarBarTintColor = .white
            let fixedSpace = McPickerBarButtonItem.fixedSpace(width: 16)
            let flexibleSpace = McPickerBarButtonItem.flexibleSpace()
            let fireButton = McPickerBarButtonItem.done(mcPicker: picker, title: "确定") // Set custom Text
            let cancelButton = McPickerBarButtonItem.cancel(mcPicker: picker, title: "取消", barButtonSystemItem: .cancel) // or system items
            picker.setToolbarItems(items: [fixedSpace, cancelButton, flexibleSpace, fireButton, fixedSpace])
            picker.show(doneHandler: { [weak self] (selections: [Int: String]) in
                if let text = selections.values.first {
                    self?.list[indexPath.section][indexPath.row].value = text
     
                }
                self?.tableView.reloadData()
            })
        }
       
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var height: CGFloat = 10
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: height))
        if section == 0 {
            height = 36
            let lab = UILabel(text: "重要信息，请认真核对", font: Font(14), nColor: UIColor(hexString: "#939AA3"))
            view.addSubview(lab)
            lab.snp.makeConstraints { make in
                make.left.equalTo(15)
                make.centerY.equalToSuperview()
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 36 : 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.01
    }
}

extension FPEditInfoVC: TZImagePickerControllerDelegate{
    func imagePickerController(_ picker: TZImagePickerController!, didSelect asset: PHAsset!, photo: UIImage!, isSelectOriginalPhoto: Bool) {
        EHUD.show("正在上传")
        uploadimage(photo)
        
    }
}
