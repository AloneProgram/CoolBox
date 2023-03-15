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
        return CGSize(width: 267 , height: 420 )
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
            make.size.equalTo(CGSize(width: 267, height: 420))
        }
        
        let titleLab = UILabel()
        titleLab.textAlignment = .center
        titleLab.font = MediumFont(16)
        titleLab.text = "用户协议与隐私政策"
        titleLab.textColor = UIColor(rgb: 51)
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(34 * kHeightScale)
            make.height.equalTo(22)
        }

        
        let introTv = UITextView()
        introTv.isEditable = false
        introTv.dataDetectorTypes = .link
        introTv.font = Font(14)
        introTv.delegate = self
        introTv.showsVerticalScrollIndicator = false
        introTv.appendLinkString(string: "感谢您选择欢电APP！\n我们非常重视您的个人信息和隐私保护，为了更好地保障您的权益，请您在使用我们的产品前，务必审慎阅读我们的")
        introTv.appendLinkString(string: "《用户协议》", withURLString: userSerUrl())
        introTv.appendLinkString(string: "和")
        introTv.appendLinkString(string: "《隐私政策》", withURLString: policyUrl())
        introTv.appendLinkString(string: "内的所有条款。\n如果您同意以上协议内容，请点击“同意并继续”，开始体验我们的产品和服务！\n您点击“同意并继续”的行为即表示您已阅读完毕并同意以上协议的全部内容。")
        introTv.backgroundColor = .clear
        introTv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#FF6B01"),
                                      NSAttributedString.Key.font: Font(14)]
        contentView.addSubview(introTv)
        
        let unAgreeBtn = UIButton(borderTitle: "不同意", font: Font(13), titleColor: UIColor(hexString: "#FF6B00"))
        unAgreeBtn.tag = 10
        unAgreeBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        contentView.addSubview(unAgreeBtn)
        unAgreeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(26)
            make.bottom.equalTo(-15)
            make.height.equalTo(36)
//            make.size.equalTo(CGSize(width: 95, height: 50))
        }
        
        introTv.snp.makeConstraints { (make) in
            make.top.equalTo(titleLab.snp.bottom).offset(5)
            make.left.equalTo(10)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(unAgreeBtn.snp.top).offset(-20)
        }
        
        let agreeBtn = UIButton(title: "同意并继续", bgColor: UIColor(hexString: "#FF6B00"), font: Font(13))
        agreeBtn.tag = 20
        agreeBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        contentView.addSubview(agreeBtn)
        agreeBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-26)
            make.bottom.equalTo(unAgreeBtn)
            make.height.equalTo(unAgreeBtn)
            make.width.equalTo(unAgreeBtn)
            make.left.equalTo(unAgreeBtn.snp.right).offset(15)
        }
        
        let lineLab = UILabel()
        lineLab.backgroundColor = UIColor(hexString: "#F0F0F0")
        contentView.addSubview(lineLab)
        lineLab.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalTo(unAgreeBtn.snp.top).offset(-11)
        }
    }
}

extension PrivacyProtocolAlert: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.relativeString == userSerUrl() ||  URL.relativeString == policyUrl() {
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
        let attrs = [NSAttributedString.Key.font : self.font!,
                     NSAttributedString.Key.paragraphStyle: paraph,
                     NSAttributedString.Key.foregroundColor: UIColor(hexString: "#7B7E90")]
        let appendString = NSMutableAttributedString(string: string, attributes:attrs)
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
