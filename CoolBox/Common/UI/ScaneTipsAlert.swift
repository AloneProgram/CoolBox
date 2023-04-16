//
//  ScaneTipsAlert.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/16.
//

import UIKit

class ScaneTipsAlert: PresentCenterVC {
    private var btn = LeftImageButton(type: .custom)
    
    override var enableTouchToDismiss: Bool {
        return false
    }
    
    override var controllerSize: CGSize {
        return CGSize(width: 270 , height: 200)
    }
    
    
    init(){
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
        if(btn.isSelected) {
            UserDefaults.standard.set(true, forKey: "HasShowScaneTipsAlert")
        }
        
        dismiss(animated: true, completion: nil)
    }
}

private extension ScaneTipsAlert {
    func setupSubviews(){
        

        let titleLab = UILabel()
        titleLab.textAlignment = .center
        titleLab.font = MediumFont(17)
        titleLab.text = "扫描增值税发票上的二维码"
        titleLab.textColor = UIColor(hexString: "#1D2129")
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(13)
            make.height.equalTo(24)
        }
        
        var att = NSMutableAttributedString(string: "请对准增值税发票上的二维码扫描，扫描成功会自动导入")
        att.addAttributes([NSAttributedString.Key.font: BoldFont(15)], range: NSRange(location: 3, length: 5))
        let contentLab = UILabel()
        contentLab.textAlignment = .left
        contentLab.font = Font(15)
        contentLab.attributedText = att
        contentLab.numberOfLines = 0
        contentLab.textColor = UIColor(hexString: "#4E5969")
        view.addSubview(contentLab)
        contentLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.left.equalTo(16)
            make.top.equalTo(titleLab.snp.bottom).offset(12)
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
       
        btn.setTitle("不再提醒", for: .normal)
        btn.setImage(UIImage(named: "ic_agree_nor"), for: .normal)
        btn.setImage(UIImage(named: "ic_agree_sel"), for: .selected)
        btn.titleLabel?.font = Font(12)
        btn.setTitleColor(UIColor(hexString: "#1D2129"), for: .normal)
        btn.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(lineLab.snp.top).offset(-10)
            make.height.equalTo(22)
        }
        
        let singleBtn = UIButton(type: .custom)
        singleBtn.setTitle("开始扫码", for: .normal)
        singleBtn.titleLabel?.font = Font(18)
        singleBtn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        singleBtn.tag = 10
        singleBtn.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        view.addSubview(singleBtn)
        singleBtn.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(lineLab.snp.bottom)
        }
    }

    @objc func selectAction() {
        btn.isSelected = !btn.isSelected
    }
}
