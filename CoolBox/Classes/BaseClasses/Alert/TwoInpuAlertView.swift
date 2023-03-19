//
//  TwoInpuAlertView.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/18.
//

import UIKit

class TwoInpuAlertView: UIView {
  
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var vCodeTF: UITextField!
    
    @IBOutlet weak var getVCode: CusCodeBtn!
    
    var clickBlock:((String) -> Void)?
    
    class func instance() -> TwoInpuAlertView {
        return UINib(nibName: "TwoInpuAlertView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! TwoInpuAlertView
    }

    override func awakeFromNib() {
        
        getVCode.maxSecond = 60
        getVCode.setTitle("获取验证码", for: .normal)
        getVCode.setTitle("重新发送(second)", for: .disabled)
        getVCode.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        getVCode.setTitleColor(UIColor(hexString: "#C9CDD4"), for: .disabled)
    }
    
    @IBAction func getVCodeAction(_ sender: Any) {
        if let text = phoneTF.text, AppSecurity.checkTelNumber(text) {
            clickBlock?(text)
        }else {
            EToast.showFailed("手机号格式不正确")
        }
        
    }
}
