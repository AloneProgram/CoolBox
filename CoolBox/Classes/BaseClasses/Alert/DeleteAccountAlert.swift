//
//  DeleteAccountAlert.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

class DeleteAccountAlert: PresentCenterVC {
    
    override var enableTouchToDismiss: Bool {
        return false
    }
    
    override var controllerSize: CGSize {
        return CGSize(width: 270 , height: 226)
    }
    
    private var titleHeight: CGFloat = 21
    private var contentHeight: CGFloat = 0
    
    private var titleStr = ""
    private var contentStr = ""
    private var leftBtnTitleStr = ""
    private var rightBtnTitleStr = ""
    
    
    private var confirmClosure: (() -> Void)?
    private var cancleClosure: (() -> Void)?
    
    init(title: String = "注销账号", cancleTitle: String = "确认注销", confirmTitle: String = "再想想", cancle: (() -> Void)? = nil, confirm: (() -> Void)? = nil) {
        titleStr = title
        leftBtnTitleStr = cancleTitle
        rightBtnTitleStr = confirmTitle
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
            confirmClosure?()
            dismiss(animated: true, completion: nil)
        }
    }
}

private extension DeleteAccountAlert {
    func setupSubviews(){
        let titleLab = UILabel()
        titleLab.textAlignment = .center
        titleLab.font = MediumFont(16)
        titleLab.text = titleStr
        titleLab.textColor = UIColor(rgb: 51)
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(30)
            make.height.equalTo(titleHeight)
        }
        
        let topMsgLabel = UILabel()
        topMsgLabel.numberOfLines = 0
        topMsgLabel.font = SCFont(12)
        topMsgLabel.attributed.text = """
        账号注销后将 \("永久清空", .font(BoldFont(12))) 该账号所有数据且 \("不可恢复", .font(BoldFont(12)))，请谨慎操作。
        """
        view.addSubview(topMsgLabel)
        topMsgLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(21)
            make.top.equalTo(titleLab.snp.bottom).offset(13)
        }

        let tips = UILabel(text: "注销请求提交后，我们将于7个工作日内处理您的注销请求。在此期间，您可正常登录，任意时间登录都将默认取消您的注销请求。", font: SCFont(10), nColor: UIColor(hexString: "#86909C"))
        tips.numberOfLines = 0
        view.addSubview(tips)
        tips.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(topMsgLabel)
            make.top.equalTo(topMsgLabel.snp.bottom).offset(8)
        }
      
        
        let lineLab = UILabel()
        lineLab.backgroundColor = UIColor(hexString: "#000000", alpha: 0.1)
        view.addSubview(lineLab)
        lineLab.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalTo(-45)
        }
  

        let cancleBtn = UIButton(type: .custom)
        cancleBtn.setTitle(leftBtnTitleStr, for: .normal)
        cancleBtn.titleLabel?.font = Font(16)
        cancleBtn.setTitleColor(UIColor(hexString: "#F53F3F"), for: .normal)
        cancleBtn.tag = 10
        cancleBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        view.addSubview(cancleBtn)
        cancleBtn.snp.makeConstraints { (make) in
            make.bottom.left.equalToSuperview()
            make.top.equalTo(lineLab.snp.bottom)
        }
        
        let verLine = UILabel()
        verLine.backgroundColor = UIColor(hexString: "#F0F0F0")
        view.addSubview(verLine)
        verLine.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(24)
            make.top.equalTo(lineLab.snp.bottom).offset(13)
        }

        let confirmBtn = UIButton(type: .custom)
        confirmBtn.setTitle(rightBtnTitleStr, for: .normal)
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
