//
//  CompanyInviteAlert.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

class CompanyInviteAlert: PresentCenterVC {
    override var enableTouchToDismiss: Bool {
        return true
    }
    
    override var controllerSize: CGSize {
        return CGSize(width: 270 , height: 186)
    }
    
    private var titleHeight: CGFloat = 21
    private var contentHeight: CGFloat = 0
    
    private var titleStr = ""
    private var contentStr = ""
    private var placeStr = ""
    private var leftBtnTitleStr = ""
    private var rightBtnTitleStr = ""
    
    private var textField = UITextField()
    
    
    //是否是单个按钮
    private var isSingle = false
    
    private var confirmClosure: ((String) -> Void)?
    private var cancleClosure: (() -> Void)?
    
    init(title: String = "提示", content: String, placeText: String? = "", cancleTitle: String = "取消", confirmTitle: String = "确定", single: Bool = false, cancle: (() -> Void)? = nil, confirm: ((String) -> Void)? = nil) {
        titleStr = title
        contentStr = content
        placeStr = placeText ?? ""
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
            guard let text = textField.text else {
                EToast.showFailed("邀请码不可为空")
                return
            }
            confirmClosure?(text)
            dismiss(animated: true, completion: nil)
        }
    }

}

private extension CompanyInviteAlert {
    func setupSubviews(){
        let titleLab = UILabel()
        titleLab.textAlignment = .center
        titleLab.font = MediumFont(17)
        titleLab.text = titleStr
        titleLab.textColor = UIColor(hexString: "#1D2129")
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(10)
            make.height.equalTo(24)
        }
        
        let contentLab = UILabel()
        contentLab.textAlignment = .center
        contentLab.font = SCFont(15)
        contentLab.text = contentStr
        contentLab.textColor = UIColor(hexString: "#4E5969")
        view.addSubview(contentLab)
        contentLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLab.snp.bottom).offset(15)
            make.height.equalTo(22)
        }
        
        textField.text = placeStr
        textField.backgroundColor = UIColor(hexString: "#F2F3F5")
        textField.cornerRadius = 2
        textField.font = SCFont(14)
        let leftview = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        let lab = UILabel(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        leftview.addSubview(lab)
    
        textField.leftView = leftview
        textField.leftViewMode = .always
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(16)
            make.height.equalTo(36)
            make.top.equalTo(contentLab.snp.bottom).offset(24)
        }
        
   
        let lineLab = UILabel()
        lineLab.backgroundColor = UIColor(hexString: "#E5E6EB")
        view.addSubview(lineLab)
        lineLab.snp.makeConstraints { (make) in
            make.left.centerX.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(textField.snp.bottom).offset(11)
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
}
