//
//  TwoInputAlert.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/18.
//

import UIKit

class TwoInputAlert: PresentCenterVC {
    override var enableTouchToDismiss: Bool {
        return true
    }
    
    override var controllerSize: CGSize {
        return CGSize(width: 340 , height: 268)
    }
    
    private var titleHeight: CGFloat = 21
    private var contentHeight: CGFloat = 0
    
    private var titleStr = ""
    private var placeStr = ""
    private var leftBtnTitleStr = ""
    private var rightBtnTitleStr = ""
    
    private var inputTFView = TwoInpuAlertView.instance()
    
    //是否是单个按钮
    private var isSingle = false
    
    private var confirmClosure: ((String, String) -> Void)?
    private var cancleClosure: (() -> Void)?
    
    init(title: String = "修改手机号码", cancleTitle: String = "取消", confirmTitle: String = "确定", single: Bool = false, cancle: (() -> Void)? = nil, confirm: ((String, String) -> Void)? = nil) {
        titleStr = title
        leftBtnTitleStr = cancleTitle
        rightBtnTitleStr = confirmTitle
        isSingle = single
        cancleClosure = cancle
        confirmClosure = confirm
  
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.cornerRadius = 8
        view.masksToBounds = true
        setupSubviews()
    }
    
    @objc func buttonClick(_ sender: UIButton) {
        if sender.tag == 10 {
            cancleClosure?()
            dismiss(animated: true, completion: nil)
        }else if sender.tag == 20 {
            guard let phone = inputTFView.phoneTF.text else {
                EToast.showFailed("手机号不能为空")
                return
            }
            guard AppSecurity.checkTelNumber(phone) else {
                EToast.showFailed("手机号格式不正确")
                return
            }
                
            guard let code = inputTFView.vCodeTF.text, code.length > 0 else {
                EToast.showFailed("验证码不能为空")
                return
            }
            
            confirmClosure?(phone, code)
            dismiss(animated: true, completion: nil)
        }
    }

}

private extension TwoInputAlert {
    func setupSubviews(){
        let titleLab = UILabel()
        titleLab.textAlignment = .center
        titleLab.font = MediumFont(17)
        titleLab.text = titleStr
        titleLab.textColor = UIColor(rgb: 51)
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(20)
            make.height.equalTo(titleHeight)
        }
        
        inputTFView.clickBlock = {[weak self] phone in
            self?.getCode(phone: phone)
        }
        view.addSubview(inputTFView)
        inputTFView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLab.snp.bottom)
            make.height.equalTo(180)
        }
   
        let lineLab = UILabel()
        lineLab.backgroundColor = UIColor(hexString: "#E5E6EB")
        view.addSubview(lineLab)
        lineLab.snp.makeConstraints { (make) in
            make.left.centerX.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(inputTFView.snp.bottom)
        }
        
        if isSingle {
            let singleBtn = UIButton(type: .custom)
            singleBtn.setTitle(leftBtnTitleStr, for: .normal)
            singleBtn.titleLabel?.font = Font(14)
            singleBtn.setTitleColor(UIColor(hexString: "#FF6B00"), for: .normal)
            singleBtn.tag = 10
            singleBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
            view.addSubview(singleBtn)
            singleBtn.snp.makeConstraints { (make) in
                make.left.bottom.right.equalToSuperview()
                make.top.equalTo(lineLab.snp.bottom)
            }
            return
        }


        let cancleBtn = UIButton(type: .custom)
        cancleBtn.setTitle(leftBtnTitleStr, for: .normal)
        cancleBtn.titleLabel?.font = Font(14)
        cancleBtn.setTitleColor(UIColor(hexString: "#1D2129"), for: .normal)
        cancleBtn.tag = 10
        cancleBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        view.addSubview(cancleBtn)
        cancleBtn.snp.makeConstraints { (make) in
            make.bottom.left.equalToSuperview()
            make.top.equalTo(lineLab.snp.bottom)
        }
        
        let verLine = UILabel()
        verLine.backgroundColor = UIColor(hexString: "#E5E6EB")
        view.addSubview(verLine)
        verLine.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(44)
            make.top.equalTo(lineLab.snp.bottom)
        }

        let confirmBtn = UIButton(type: .custom)
        confirmBtn.setTitle(rightBtnTitleStr, for: .normal)
        confirmBtn.titleLabel?.font = Font(14)
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
    
    func getCode(phone: String) {
        //自动选中验证码输入框
        inputTFView.vCodeTF.becomeFirstResponder()
        
        LoginApi.getSmsCode(phone: phone, type: 2) { [weak self] success in
            if success {
                self?.inputTFView.getVCode.countdown = true
            }
        }
    }
}
