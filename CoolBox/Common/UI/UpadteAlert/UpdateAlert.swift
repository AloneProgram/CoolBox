//
//  UpdateAlert.swift
//  huandian
//
//  Created by jhin on 2021/1/18.
//  Copyright © 2021 immptor. All rights reserved.
//

import UIKit

class UpdateAlert: PresentCenterVC {
    private var versonModel: VersionModel?
    
    override var enableTouchToDismiss: Bool {
        if let forceUpgrade = versonModel?.forceUpdate {
            return !forceUpgrade
        }
        return true
    }
    
    override var controllerSize: CGSize {
        return CGSize(width: 267 * kWidthScale, height: 208 + contentHeight)
    }
    
    private var contentHeight: CGFloat = 0
    
    init(versonModel: VersionModel?) {
        self.versonModel = versonModel
        if let desc = versonModel?.desc {
            contentHeight = desc.heightWithConstrainedWidth(width: 207, font: SCFont(14))
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupSubviews()
    }
    
    @objc func buttonClick(_ sender: UIButton) {
        if let enableDissmiss = versonModel?.forceUpdate, enableDissmiss{  //强更，弹窗不消失
            if sender.tag == 20 {
                guard let urlStr = versonModel?.url, urlStr.length != 0, let url = URL(string: urlStr) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else if sender.tag == 30 || sender.tag == 40 {
                exit(0)
            } else{
                dismiss(animated: true, completion: nil)
            }
        }else {
            dismiss(animated: true) { [weak self] in
                if sender.tag == 20 {
                    guard let urlStr = self?.versonModel?.url, urlStr.length != 0, let url = URL(string: urlStr) else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

private extension UpdateAlert {
    func setupSubviews() {
        
        let bgImagView = UIImageView(image: R.image.update_bg())
        view.addSubview(bgImagView)
        bgImagView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let topbg = UIImageView(image: R.image.update_top())
        view.addSubview(topbg)
        topbg.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(94)
        }
        
        let rocket = UIImageView(image: R.image.update_rocket())
        view.addSubview(rocket)
        rocket.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 110, height: 100))
            $0.top.equalTo(-42)
        }
        
        let clostBtn = UIButton(type: .custom)

        clostBtn.setBackgroundImage(R.image.update_close(), for: .normal)
        clostBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        view.addSubview(clostBtn)
        clostBtn.snp.makeConstraints {
            $0.top.equalTo(8)
            $0.right.equalTo(-8)
            $0.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        let titleLab = UILabel()
        titleLab.textAlignment = .center
        titleLab.font = SCMediumFont(16)
        titleLab.textColor = UIColor(hexString: "#16193C")
        titleLab.text = "发现新版本"
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(rocket.snp.bottom).offset(12)
            $0.height.equalTo(22)
        }
        
        let contentLab = UILabel()
        contentLab.numberOfLines = 0
        contentLab.text = versonModel?.desc
        contentLab.textColor = UIColor(hexString: "#7B7E90")
        contentLab.font = SCFont(14)
        view.addSubview(contentLab)
        contentLab.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.equalTo(30)
            $0.top.equalTo(topbg.snp.bottom).offset(14)
            $0.bottom.equalTo(-100)
        }

        let updateBtn = UIButton(title: "立即升级", bgColor: UIColor(hexString: "#FF6B00"))
        updateBtn.tag = 20
        updateBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)

        var cancelTitle = "下次再说"
        //  强更
        if let forceUpgrade =  versonModel?.forceUpdate, forceUpgrade {
            cancelTitle = "退出"
            clostBtn.tag = 30
        }
        let cancleBtn = UIButton(borderTitle: cancelTitle, bgColor: UIColor(hexString: "#FF6B00", alpha: 0.05), borderColor: UIColor(hexString: "#FF6B00"), font: SCFont(14), radius: 4, titleColor: UIColor(hexString: "#FF6B00"))
        cancleBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        if let forceUpgrade =  versonModel?.forceUpdate, forceUpgrade {
            cancleBtn.tag = 40
        }
        view.addSubview(cancleBtn)
        cancleBtn.snp.makeConstraints {
            $0.left.equalTo(30)
            $0.bottom.equalTo(-24)
            $0.size.equalTo(CGSize(width: 98 * kWidthScale, height: 44))
        }
        
        view.addSubview(updateBtn)
        updateBtn.snp.makeConstraints {
            $0.right.equalTo(-30)
            $0.bottom.equalTo(-24)
            $0.size.equalTo(CGSize(width: 98 * kWidthScale, height: 44))
        }
    }
}

struct UpdateAlertTool {
    static func updateAlertShow(_ vc: UIViewController? = nil) {
        let _ = delay(1) {
            VersionUpdateApi.versionUpdate { (model) in
                if let model = model {
                    let hasShow = UserDefaults.standard.bool(forKey: "VersionAlertHasShow_\(model.version)") && vc == nil
                    //强更直接弹出, 非强更需判断是否弹出过(关于页面不判断是否弹出)
                    let chanShow = model.forceUpdate ? true : !hasShow
                    if chanShow {
                        // app版本小于服务器版本,弹出更新弹窗
                        UpdateAlertTool.alertShow(UpdateAlert(versonModel: model), vc: vc)
                        if !model.forceUpdate {  //非强更弹窗只弹出一次
                            UserDefaults.standard.set(true, forKey: "VersionAlertHasShow_\(model.version)")
                        }
                    }
                }
            }
        }
    }
    
    private static func alertShow(_ alert: UpdateAlert, vc: UIViewController?){
        alert.modalPresentationStyle = .custom
        alert.transitioningDelegate = alert
        
        if vc != nil {
            vc?.present(alert, animated: true, completion: nil)
        }else if let nav = UIApplication.shared.delegate?.window??.rootViewController  {
            nav.present(alert, animated: true, completion: nil)
        }
    }
}


fileprivate enum ApiTarget: ETargetType {
    case appVersion(_ version: String)
    
    var path: String {
        switch self {
        case .appVersion: return "/app/version"
        }
    }
    
    var method: Method {
        switch self {
        default: return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .appVersion(let verison):
            return [
                "appType": 2,
                "version": verison
            ]
        }
    }
}

struct VersionUpdateApi {
    static func versionUpdate(_ result: @escaping (VersionModel?)->Void) {
        let infoDictionary = Bundle.main.infoDictionary
        guard let version :String = infoDictionary!["CFBundleShortVersionString"] as? String else { return }
        let v = "v"+version
        let target = ApiTarget.appVersion(v)
        ENetworking.request(target, success: { (json) in
            result(VersionModel(json))
        }) { (err, json) in
            print("versionUpdate error = ", json.debugDescription)
            result(nil)
        }
    }
}


struct VersionModel  {
    /// 更新说明
    var desc = "版本更新"
    /// 是否强更
    var forceUpdate = false
    /// 更新URL
    var url = "itms-apps://itunes.apple.com/app/id1544702867"
    /// 版本号
    var version = ""
    
    init(_ json: JSON?) {
        guard let json = json else { return }
        let tmpDesc = json["desc"].stringValue.replacingOccurrences(of: "；", with: ";")
        desc = tmpDesc.replacingOccurrences(of: ";", with: ";\n")
        if desc.hasSuffix(";\n") {
            desc.removeLast(1)
        }
        forceUpdate = json["forceUpdate"].intValue == 1
        let str = json["url"].stringValue
        if str.length > 0 {
            url = str
        }

        version = json["version"].stringValue
    }
}
