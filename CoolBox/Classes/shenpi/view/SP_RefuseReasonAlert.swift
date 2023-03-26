//
//  SP_RefuseReasonAlert.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

class SP_RefuseReasonAlert: PresentBottomVC {
    
    private var resonBlock: ((String) -> Void)?
    
    override var enableTouchToDismiss: Bool {
        return false
    }
    
    override var controllerHeight: CGFloat {
        return 333 + kBottomSpace
    }
    
    var textview = ETextView()
    
    init( handle:  ((String) -> Void)? = nil) {
        resonBlock = handle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let maskPath = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8))
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
        
        let titleLabel = UILabel(text: "确认拒绝吗？", font: MediumFont(18), nColor: UIColor(hexString: "#1D2129"))
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(9)
            make.centerX.equalToSuperview()
        }
        
        let canleBtn = UIButton(type: .custom)
        canleBtn.setTitle("取消", for: .normal)
        canleBtn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        canleBtn.titleLabel?.font = Font(16)
        canleBtn.addTarget(self, action: #selector(cancleAction), for: .touchUpInside)
        view.addSubview(canleBtn)
        canleBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(20)
            make.height.equalTo(20)
            make.width.equalTo(40)
        }
        
        
        let sureBtn = UIButton(type: .custom)
        sureBtn.setTitle("确认拒绝", for: .normal)
        sureBtn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        sureBtn.titleLabel?.font = Font(16)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        view.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.top.equalTo(15)
            make.height.equalTo(30)
            make.width.equalTo(70)
        }
        
        textview.hideNumLabel = true
        textview.placeHolderText = "请输入审批意见"
        textview.placeholderTextFont = SCFont(16)
        textview.placeholderTextColor = UIColor(hexString: "#86909C")
        textview.textColor = UIColor(hexString: "#1D2129")
        view.addSubview(textview)
        textview.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerX.equalToSuperview()
            make.top.equalTo(64)
            make.bottom.equalTo(-(20 + kBottomSpace))
        }
    
    }

    @objc func sureAction() {
        if textview.text.length > 0 {
            resonBlock?(textview.text)
            dismiss(animated: true, completion: nil)
        }else {
            EToast.showInfo("请输入审批意见")
        }
        
    }

    @objc func cancleAction(){
        dismiss(animated: true, completion: nil)
    }
}
