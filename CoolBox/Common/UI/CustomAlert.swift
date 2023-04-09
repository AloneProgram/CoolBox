//
//  CustomAlert.swift
//  huandian
//
//  Created by Jhin on 2020/11/9.
//  Copyright © 2020 immptor. All rights reserved.
//

import UIKit

class CustomAlert: PresentCenterVC {
    
    var enableTouchBlank = true
    
    override var enableTouchToDismiss: Bool {
        return enableTouchBlank
    }    
    
    override var controllerSize: CGSize {
        let height = 13 + titleHeight + 20 + contentHeight + 64
        return CGSize(width: 270 , height: height)
    }
    
    private var titleHeight: CGFloat = 21
    private var contentHeight: CGFloat = 0
    
    private var titleStr = ""
    private var contentStr = ""
    private var leftBtnTitleStr = ""
    private var rightBtnTitleStr = ""
    
    
    //是否是单个按钮
    private var isSingle = false
    
    typealias ConfirmClosure = () -> Void
    private var confirmClosure: ConfirmClosure?
    private var cancleClosure: ConfirmClosure?
    
    init(title: String = "提示", content: String = "", cancleTitle: String = "取消", confirmTitle: String = "确认", single: Bool = false, cancle: ConfirmClosure? = nil, confirm: ConfirmClosure? = nil) {
        titleStr = title
        contentStr = content
        leftBtnTitleStr = cancleTitle
        rightBtnTitleStr = confirmTitle
        isSingle = single
        cancleClosure = cancle
        confirmClosure = confirm
        if content.length > 0 {
            contentHeight = contentStr.heightWithConstrainedWidth(width: 285 - 50, font: Font(14)) + 5
        }else {
            contentHeight = 0
        }
        
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

private extension CustomAlert {
    func setupSubviews(){
        let titleLab = UILabel()
        titleLab.textAlignment = .center
        titleLab.font = MediumFont(17)
        titleLab.text = titleStr
        titleLab.textColor = UIColor(hexString: "#1D2129")
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(13)
            make.height.equalTo(titleHeight)
        }
        
        let contentLab = UILabel()
        contentLab.textAlignment = .center
        contentLab.font = Font(14)
        contentLab.text = contentStr
        contentLab.numberOfLines = 0
        contentLab.textColor = UIColor(hexString: "#86909C")
        view.addSubview(contentLab)
        contentLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(16)
            make.top.equalTo(titleLab.snp.bottom).offset(20)
            make.height.equalTo(contentHeight)
        }
        
        let lineLab = UILabel()
        lineLab.backgroundColor = UIColor(hexString: "#000000", alpha: 0.1)
        view.addSubview(lineLab)
        lineLab.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.centerX.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(contentLab.snp.bottom).offset(20)
        }
        
        if isSingle {
            let singleBtn = UIButton(type: .custom)
            singleBtn.setTitle(leftBtnTitleStr, for: .normal)
            singleBtn.titleLabel?.font = Font(18)
            singleBtn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
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
        cancleBtn.titleLabel?.font = Font(16)
        cancleBtn.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
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
            make.bottom.equalToSuperview()
            make.top.equalTo(lineLab.snp.bottom)
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
