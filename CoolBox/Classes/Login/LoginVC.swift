//
//  LoginVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/16.
//

import UIKit
import SnapKit
import AttributedString

class LoginVC: EViewController {
    
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var verCodeTF: UITextField!
    
    @IBOutlet weak var codeBtn: CusCodeBtn!
    
    @IBOutlet weak var loginBtn: UIButton!
    private let selectBtn = UIButton()
    
    
    private var validPhone = false
    private var validSmsCode = false
    private var hasAgree = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        
        codeBtn.maxSecond = 60
        codeBtn.setTitle("获取验证码", for: .normal)
        codeBtn.setTitle("重新发送(second)", for: .disabled)
        codeBtn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        codeBtn.setTitleColor(UIColor(hexString: "#C9CDD4"), for: .disabled)
        
        let tipsLabel = UILabel()
        tipsLabel.numberOfLines = 0
        tipsLabel.font = SCFont(12)
        tipsLabel.textAlignment = .center
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(20)
            make.bottom.equalTo(loginBtn.snp.top).offset(-20)
        }
        
        tipsLabel.textColor = UIColor(hexString: "#1D2129")
        tipsLabel.attributed.text = """
        我已阅读并同意 \("用户协议",
        .foreground(UIColor(hexString: "#165DFF")),.action(clickPlicy)) 和 \("隐私政策", .foreground(UIColor(hexString: "#165DFF")),.action(clickPrivicy))
        """
        
        selectBtn.isSelected = false
        selectBtn.setImage(UIImage(named: "ic_agree_nor"), for: .normal)
        selectBtn.setImage(UIImage(named: "ic_agree_sel"), for: .selected)
        selectBtn.addTarget(self, action: #selector(agreeProtocol), for: .touchUpInside)
        view.addSubview(selectBtn)
        selectBtn.snp.makeConstraints { (make) in
            make.right.equalTo(tipsLabel.snp.left).offset(-9)
            make.centerY.equalTo(tipsLabel)
            make.size.equalTo(CGSize(width: 25, height: 25))
        }
    }
    
    
    @IBAction func getVerCode(_ sender: CusCodeBtn) {
        guard let text = phoneTF.text, AppSecurity.checkTelNumber(text)  else {
            EToast.showFailed("手机号格式不正确")
            return
        }
        guard hasAgree else {
            EToast.showFailed("请阅读并同意《用户协议》和《隐私政策》")
            verCodeTF.resignFirstResponder()
            phoneTF.resignFirstResponder()
            return
        }
        
        //自动选中验证码输入框
        verCodeTF.becomeFirstResponder()
        
        LoginApi.getSmsCode(phone: text) { success in
            if success {
                sender.countdown = true
            }
        }
    }
    
    
    @IBAction func loginAction(_ sender: Any) {
        guard hasAgree else {
            EToast.showFailed("请阅读并同意《用户协议》和《隐私政策》")
            return
        }
        guard let phone = phoneTF.text, AppSecurity.checkTelNumber(phone)  else {
            EToast.showFailed("手机号格式不正确")
            return
        }
        guard let vCode = verCodeTF.text, vCode.length > 0  else {
            EToast.showFailed("验证码不可为空")
            return
        }
        LoginApi.phoneLogin(phone: phone, smsCode: vCode) { success in
            if success {
                let keyWindow = UIApplication.shared.delegate?.window
                if Login.currentAccount().nickname.contains("****") {
                    //未修改昵称(新用户注册昵称为手机号,中间4为变为****)
                    keyWindow??.rootViewController = CompleteInfoVC()
                }else {
                   
                    keyWindow??.rootViewController = AppTabBarController()
                }
            }
        }
    }
    
    func clickPlicy(_ result: ASAttributedString.Action.Result) {
        pushToWebView(UserAreegemnt)
    }
    
    func clickPrivicy(_ result: ASAttributedString.Action.Result) {
        pushToWebView(PrivacyPlice)
    }
    
    @objc private func agreeProtocol() {
        selectBtn.isSelected = !selectBtn.isSelected
        hasAgree = selectBtn.isSelected
    }
}


