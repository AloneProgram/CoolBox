//
//  EmailImportAlert.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/1.
//

import UIKit

class EmailImportAlert: PresentCenterVC {

    var enableTouchBlank = true
    
    override var enableTouchToDismiss: Bool {
        return enableTouchBlank
    }
    
    override var controllerSize: CGSize {
        let height: CGFloat = 190 + 16 + emailtHeight
        return CGSize(width: 270 , height: height)
    }
    
    private var titleHeight: CGFloat = 21
    private var emailtHeight: CGFloat = 0
    
    private var titleStr = ""
    private var emailStr = ""
    private var leftBtnTitleStr = ""
    private var rightBtnTitleStr = ""
    
    
    //是否是单个按钮
    private var isSingle = false
    
    typealias ConfirmClosure = () -> Void
    private var confirmClosure: ConfirmClosure?
    private var cancleClosure: ConfirmClosure?
    
    init(title: String = "邮箱导入", email: String = "", cancleTitle: String = "取消", confirmTitle: String = "导入", single: Bool = false, cancle: ConfirmClosure? = nil, confirm: ConfirmClosure? = nil) {
        titleStr = title
        emailStr = Login.currentAccount().email
        leftBtnTitleStr = cancleTitle
        rightBtnTitleStr = confirmTitle
        isSingle = single
        cancleClosure = cancle
        confirmClosure = confirm
        
        emailtHeight = email.heightWithConstrainedWidth(width: 175, font: Font(12))
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.cornerRadius = 4
        view.masksToBounds = true
        setupSubviews()
    }
    
    @objc func buttonClick(_ sender: UIButton) {
        if sender.tag == 10 {
            cancleClosure?()
            dismiss(animated: true, completion: nil)
        }else if sender.tag == 20 {
            confirmClosure?()
            dismiss(animated: true, completion: nil)
        }
    }
}

private extension EmailImportAlert {
    func setupSubviews(){
        let titleLab = UILabel()
        titleLab.textAlignment = .center
        titleLab.font = MediumFont(17)
        titleLab.text = titleStr
        titleLab.textColor = UIColor(hexString: "#1D2129")
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(16)
            make.height.equalTo(titleHeight)
        }
        
        let contentLab = UILabel()
        contentLab.textAlignment = .left
        contentLab.font = Font(14)
        contentLab.textColor = UIColor(rgb: 51)
        let att = NSMutableAttributedString(string: "请将电子发票发送到专属邮箱中后，点击【导入】按钮导入发票")
        let rang1 = NSRange(location: 9, length: 4)
        let rang2 = NSRange(location: 19, length: 2)
        att.addAttributes([.font: BoldFont(14), .foregroundColor: UIColor(hexString: "#165DFF")], range: rang1)
        att.addAttributes([.foregroundColor: UIColor(hexString: "#165DFF")], range: rang2)
        contentLab.attributedText = att
        contentLab.numberOfLines = 0
        view.addSubview(contentLab)
        contentLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.left.equalTo(20)
            make.top.equalTo(titleLab.snp.bottom).offset(21)
            make.height.equalTo(44)
        }
        
        let emailView = UIView()
        emailView.cornerRadius = 2
        emailView.backgroundColor = UIColor(hexString: "#F2F3F5")
        view.addSubview(emailView)
        emailView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(contentLab.snp.bottom).offset(30)
            make.size.equalTo(CGSize(width: 238, height: emailtHeight + 16))
        }
        
        let emailLab = UILabel(text: emailStr, font: Font(12), nColor: UIColor(hexString: "#1D2129"))
        emailLab.numberOfLines = 0
        emailView.addSubview(emailLab)
        emailLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
            make.top.equalTo(8)
            make.width.equalTo(175)
        }
        
        let copyBtn = UIButton(type: .custom)
        copyBtn.setTitle("复制", for: .normal)
        copyBtn.backgroundColor = .clear
        copyBtn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        copyBtn.titleLabel?.font = Font(14)
        copyBtn.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        emailView.addSubview(copyBtn)
        copyBtn.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(48)
        }
        
        
        let lineLab = UILabel()
        lineLab.backgroundColor = UIColor(hexString: "#000000", alpha: 0.1)
        view.addSubview(lineLab)
        lineLab.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.centerX.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(emailView.snp.bottom).offset(10)
        }
        
        
        let verLine = UILabel()
        verLine.backgroundColor = UIColor(hexString: "#F0F0F0")
        view.addSubview(verLine)
        verLine.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(0.5)
            make.bottom.equalToSuperview()
            make.top.equalTo(lineLab.snp.bottom)
        }
        
        
        let cancleBtn = UIButton(type: .custom)
        cancleBtn.setTitle(leftBtnTitleStr, for: .normal)
        cancleBtn.titleLabel?.font = Font(16)
        cancleBtn.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
        cancleBtn.tag = 10
        cancleBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        view.addSubview(cancleBtn)
        cancleBtn.snp.makeConstraints { (make) in
            make.bottom.left.equalToSuperview()
            make.top.equalTo(lineLab.snp.bottom)
            make.right.equalTo(verLine.snp.left)
        }
        
        let confirmBtn = UIButton(type: .custom)
        confirmBtn.setTitle(rightBtnTitleStr, for: .normal)
        confirmBtn.titleLabel?.font = Font(16)
        confirmBtn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        confirmBtn.tag = 20
        confirmBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        view.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.top.equalTo(cancleBtn)
            make.left.equalTo(verLine.snp.right)
        }
        
    }
    
    @objc func copyAction() {
        
    }
    
    
}
