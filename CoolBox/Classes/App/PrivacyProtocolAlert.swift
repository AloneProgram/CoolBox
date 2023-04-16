//
//  PrivacyProtocolAlert.swift
//  Livepush
//
//  Created by 周志杰 on 2020/4/24.
//  Copyright © 2020 yeting. All rights reserved.
//

import UIKit

class PrivacyProtocolAlert: PresentCenterVC {

    override var enableTouchToDismiss: Bool {
        return false
    }
    
    override var controllerSize: CGSize {
        return CGSize(width: 270 , height: 225 )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupSubviews()
    }
    
    @objc func buttonClick(_ sender: UIButton) {
        if sender.tag == 10 {
            exit(0)
        }else if sender.tag == 20 {
            UserDefaults.standard.set(true, forKey: "AgreePrivacyProtocol")
            dismiss(animated: true, completion: nil)
            
            let keyWindow = UIApplication.shared.delegate?.window
            if Login.isLogged() {
            //去除登陆限制，增加游客模式
                keyWindow??.rootViewController = AppTabBarController()
            }
            else {
                keyWindow??.rootViewController = LoginVC()
            }
        }
    }
}

private extension PrivacyProtocolAlert {
    func setupSubviews(){
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.cornerRadius = 4
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 267, height: 225))
        }
        
        let titleLab = UILabel()
        titleLab.textAlignment = .center
        titleLab.font = Font(17)
        titleLab.text = "服务协议和隐私政策"
        titleLab.textColor = UIColor(rgb: 51)
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(16)
            make.height.equalTo(22)
        }

        
        let introTv = UITextView()
        introTv.isEditable = false
        introTv.dataDetectorTypes = .link
        introTv.font = Font(14)
        introTv.delegate = self
        introTv.showsVerticalScrollIndicator = false
        introTv.appendLinkString(string: "请你务必审慎阅读、充分理解“服务协议”和“隐私政策”各条款。 你可阅读")
        introTv.appendLinkString(string: "《服务协议》", withURLString: UserAreegemnt)
        introTv.appendLinkString(string: "和")
        introTv.appendLinkString(string: "《隐私政策》", withURLString: PrivacyPlice)
        introTv.appendLinkString(string: "了解详细信息。如你同意，请点击“同意”开始接受我们的服务。")

        var attrString:NSMutableAttributedString = NSMutableAttributedString(attributedString: introTv.attributedText)
        attrString.addAttributes([NSAttributedString.Key.font: BoldFont(14)], range: NSRange(location: 13, length: 6))
        attrString.addAttributes([NSAttributedString.Key.font: BoldFont(14)], range: NSRange(location: 20, length: 6))
        introTv.attributedText = attrString
        introTv.backgroundColor = .clear
        introTv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#165DFF"),
                                      NSAttributedString.Key.font: BoldFont(14)]
        contentView.addSubview(introTv)
        
        introTv.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(5)
            make.left.equalTo(10)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-45)
        }
        
        
        let lineLab = UILabel()
        lineLab.backgroundColor = UIColor(hexString: "#000000", alpha: 0.1)
        view.addSubview(lineLab)
        lineLab.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.centerX.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalTo(-44)
        }


        let cancleBtn = UIButton(type: .custom)
        cancleBtn.setTitle("暂不同意", for: .normal)
        cancleBtn.titleLabel?.font = Font(16)
        cancleBtn.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
        cancleBtn.tag = 10
        cancleBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        view.addSubview(cancleBtn)
        cancleBtn.snp.makeConstraints { (make) in
            make.bottom.left.equalToSuperview()
            make.top.equalTo(lineLab.snp.bottom)
            make.height.equalTo(44)
        }
        
        let verLine = UILabel()
        verLine.backgroundColor = UIColor(hexString: "#F0F0F0")
        view.addSubview(verLine)
        verLine.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.bottom.equalToSuperview()
            make.top.equalTo(lineLab.snp.bottom)
        }

        let confirmBtn = UIButton(type: .custom)
        confirmBtn.setTitle("同意", for: .normal)
        confirmBtn.titleLabel?.font = Font(16)
        confirmBtn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        confirmBtn.tag = 20
        confirmBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        view.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.bottom.top.equalTo(cancleBtn)
            make.width.equalTo(cancleBtn)
            make.left.equalTo(cancleBtn.snp.right)
        }

    }
}

extension PrivacyProtocolAlert: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.relativeString == UserAreegemnt ||  URL.relativeString == PrivacyPlice {
            let webVC = EWebViewController(urlString: URL.absoluteString)
            let nav = ENavigationController(rootViewController: webVC)
            present(nav, animated: true, completion: nil)
            return false
        }
        return true
    }
}

extension UITextView {
    //添加链接文本（链接为空时则表示普通文本）
    func appendLinkString(string:String, withURLString:String = "") {
        //原来的文本内容
        let attrString:NSMutableAttributedString = NSMutableAttributedString()
        attrString.append(self.attributedText)
         
        //新增的文本内容（使用默认设置的字体样式）
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 5
        var attrs = [NSAttributedString.Key.font : self.font!,
                     NSAttributedString.Key.paragraphStyle: paraph,
                     NSAttributedString.Key.foregroundColor: UIColor(hexString: "#1D2129")]
    
        var appendString = NSMutableAttributedString(string: string, attributes:attrs)
        //判断是否是链接文字
        if withURLString != "" {
            let range:NSRange = NSMakeRange(0, appendString.length)
            appendString.beginEditing()
            appendString.addAttribute(NSAttributedString.Key.link, value:withURLString, range:range)
            appendString.endEditing()
        }
        //合并新的文本
        attrString.append(appendString)
         
        //设置合并后的文本
        self.attributedText = attrString
    }
}


struct PrivacyProTool {
    static func alertShow(){
        let hasAgree = UserDefaults.standard.bool(forKey: "AgreePrivacyProtocol")
        if !hasAgree {
            let alert = PrivacyProtocolAlert()
            alert.modalPresentationStyle = .custom
            alert.transitioningDelegate = alert
            if let nav = UIApplication.shared.delegate?.window??.rootViewController  {
                nav.present(alert, animated: true, completion: nil)
            }
        }
    }
}
