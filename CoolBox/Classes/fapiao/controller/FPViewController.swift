//
//  FPViewController.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/15.
//

import UIKit
import Parchment


struct PageTab {
    var title = ""
    var isSelected = false

    init(_ title: String, isSelected: Bool) {
        self.title = title
        self.isSelected = isSelected
    }
}



class FPViewController: EViewController {
    
    private var headerView = ImportEntranceView.instance()
    
    var filtetEntraceView = FilterEntraceView.instance()

    override var navigationBarStyle: NavigationBarStyle { return .transparentBackground }
    
    var list: [String] = [ "未报销","报销中","已报销", "无需报销"]
    
    var listVC: [FPListVC] = [ ]
        
    lazy private var pagingViewController: PagingViewController = {
        let pagingVC = PagingViewController()
        pagingVC.collectionView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 79)
        pagingVC.dataSource = self
        pagingVC.delegate = self
        pagingVC.indicatorColor =  UIColor(hexString: "#165DFF")
        pagingVC.indicatorOptions = .visible(height: 2,
                                             zIndex: Int.max,
                                             spacing: UIEdgeInsets.zero,
                                             insets: UIEdgeInsets.zero)
        pagingVC.indicatorClass = CusPagingIndicatorView.self
        pagingVC.textColor = UIColor(hexString: "#1D2129")
        pagingVC.selectedTextColor = UIColor(hexString: "#165DFF")
        pagingVC.font = Font(16)
        pagingVC.selectedFont = MediumFont(16)
        pagingVC.borderColor = .clear
        pagingVC.borderOptions = .visible(height: 0, zIndex: 1, insets: UIEdgeInsets.zero)
        pagingVC.menuItemLabelSpacing = 0
        pagingVC.menuItemSize = .fixed(width: (kScreenWidth - 79.0) / CGFloat(list.count), height: 44)
        pagingVC.menuItemSpacing = 0
        pagingVC.menuInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pagingVC.view.translatesAutoresizingMaskIntoConstraints = false
        pagingVC.view.backgroundColor = .white
        return pagingVC
    }()
    
    var filterModels: [[FIlterModel]] = [ ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EColor.viewBgColor
        self.bigLeftTitle = "导入发票"
        
        listVC = [
            FPListVC(0),
            FPListVC(1),
            FPListVC(2),
            FPListVC(3),
        ]
        
        headerView.importActionBlock = { [weak self] tag in
            self?.importAction(tag)
        }
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kNaviBarHeight)
            make.height.equalTo(140)
        }
        
        view.addSubview(pagingViewController.view)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
       
        filtetEntraceView.clickBlock = { [weak self] in
            self?.showFilter()
        }
        
        view.addSubview(filtetEntraceView)
        filtetEntraceView.snp.makeConstraints { make in
            make.top.right.equalTo(pagingViewController.view)
            make.size.equalTo(CGSize(width: 79, height: 42))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(aliPayImportRequest(_:)), name: Notification.Name("AliImportFaPiao"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(wxImportRequest(_:)), name: Notification.Name("WXImportFaPiao"), object: nil)
    }
    
    func importAction(_ tag: Int) {
        switch tag {
        case 0: scanImport()
        case 1: requestWXApiConfig()
        case 2: aliImprot()
        case 3: tabkeImport()
        case 4: emailImport()
        default:break
        }
    }
    
    func showFilter() {
        let vc = FilterVC(0, params: filterModels)
        vc.filterBlock = { [weak self] filter in
            self?.filterModels = filter
            self?.filtetEntraceView.filterBtn.isSelected = filter.count > 0
            NotificationCenter.default.post(name: Notification.Name("ReloadFapiaoListData"), object: filter)
        }
        gy_showSide({ (config) in
            config.direction = .right
            config.animationType = .translationMask
            config.sideRelative = 0.77
        }, vc)
    }
}


extension FPViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return list.count
    }
    
    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return listVC[index]
    }
    
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return  PagingIndexItem(index: index, title: list[index])
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        if let pagingIndexItem = pagingItem as? PagingIndexItem {
            let vc = listVC[pagingIndexItem.index]
            vc.loadFapiao(page: 1, block: vc.refreshBlock)
        }
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        if let pagingIndexItem = pagingItem as? PagingIndexItem {
            let vc = listVC[pagingIndexItem.index]
            vc.loadFapiao(page: 1, block: vc.refreshBlock)
        }
    }
}


extension FPViewController {
        
    func scanImport() {
        let vc = CamareImportVC(isScaneImport: true)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func wxImport(ticket: String){
        
        guard WXApi.isWXAppInstalled() else {
            EToast.showFailed("您未安装微信")
            return
        }
        
        let cardReq = WXChooseInvoiceReq()
        cardReq.appID = AppInfo.WeChat.key
        cardReq.timeStamp = UInt32(Date().timeIntervalSince1970);
        let timeStamp = "\(cardReq.timeStamp)"
        cardReq.nonceStr = "sfim_invoice"
        cardReq.cardSign = getCardSign(nonceStr: cardReq.nonceStr, timStr: timeStamp, ticket: ticket)
        
        WXApi.send(cardReq) { _ in
            
        }
    }
    
    func aliImprot() {
        let params: [String: Any] = [
            kAFServiceOptionBizParams: ["url": "/www/invoiceSelect.htm?scene=INVOICE_EXPENSE&einvMerchantId=91310114MA1GWBRD63&serverRedirectUrl=https://api.kubaoxiao.com/callback/alipay/serve"],
            kAFServiceOptionCallbackScheme: "com.kubaoxiao.coolbx"
        ]
                        
        AFServiceCenter.call(AFService.eInvoice, withParams: params) { response in
            if response?.responseCode == .success, let token = response?.result["token"] {
                NotificationCenter.default.post(name: Notification.Name("AliImportFaPiao"), object: token)
            }
        }
        
    }
    
    func tabkeImport() {
        let vc = CamareImportVC(isScaneImport: false)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func emailImport() {
        
    }
    
    func requestWXApiConfig() {
        FPApi.getWxTiket { [weak self] ticket in
            self?.wxImport(ticket: ticket)
        }
    }
    
    
    @objc func wxImportRequest(_ noti: Notification) {
        guard  let cardArr = noti.object as? [Any] else { return}
        var dicArray: [[String: Any]] = []
        cardArr.forEach { obj in
            if let o = obj as? WXInvoiceItem {
                let dic: [String: Any] = [
                    "card_id": o.cardId,
                    "encrypt_code": o.encryptCode,
                    "app_id": o.appID,
                ]
                dicArray.append(dic)
            }
        }
        guard let jsonStr = JSON(dicArray).rawString() else { return}
        EHUD.show("正在导入..")
        FPApi.wxImportFP(arrStr: jsonStr) { success in
            if success {
                EToast.showSuccess("发票导入成功")
                NotificationCenter.default.post(name: Notification.Name("ImportFPSuccess"), object: nil)
            }
        }
        
    }
    
    @objc func aliPayImportRequest(_ noti: Notification) {
        guard  let token = noti.object as? String else { return}
        EHUD.show("正在导入..")
        FPApi.aliImportFP(token: token) { success in
            EHUD.dismiss()
            if success {
                EToast.showSuccess("发票导入成功")
                NotificationCenter.default.post(name: Notification.Name("ImportFPSuccess"), object: nil)
            }
        }
    }
    
    func getCardSign(nonceStr: String, timStr: String, ticket: String) -> String {
        var cardSignDic: [String: Any] = [:]
        cardSignDic["nonceStr"] = nonceStr
        cardSignDic["timestamp"] = timStr
        cardSignDic["api_ticket"] = ticket
        cardSignDic["cardType"] = "INVOICE"
        cardSignDic["appid"] = AppInfo.WeChat.key
        
        var contentString = ""
        let values = cardSignDic.values
                
        values.forEach { v in
            if let str = v as? String {
                contentString += str
            }
        }
        return contentString.sha1()
    }
}


class CusPagingIndicatorView: PagingIndicatorView {
    override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
      super.apply(layoutAttributes)
      if let attributes = layoutAttributes as? PagingIndicatorLayoutAttributes {
        backgroundColor = attributes.backgroundColor
        frame = CGRect(origin: frame.origin, size: CGSize(width: 24, height: frame.height))
        center = layoutAttributes.center
      }
    }
}


extension String {

    ///sha1 加密
    func sha1() -> String {
      //UnsafeRawPointer
      let data = self.data(using: String.Encoding.utf8)!
      var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
      let newData = NSData.init(data: data)
      CC_SHA1(newData.bytes, CC_LONG(data.count), &digest)
      let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
      for byte in digest {
          output.appendFormat("%02x", byte)
      }
      return output as String
  }
}
