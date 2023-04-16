//
//  tpTipsAlert.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/16.
//

import UIKit

class tpTipsAlert: PresentCenterVC {

    private var btn = LeftImageButton(type: .custom)
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override var enableTouchToDismiss: Bool {
        return false
    }
    
    override var controllerSize: CGSize {
        return CGSize(width: 270 , height: 308)
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
            UserDefaults.standard.set(true, forKey: "HasShowTpTipsAlert")
        }
        
        dismiss(animated: true, completion: nil)
    }
}

private extension tpTipsAlert {
    func setupSubviews(){
        
        let img = UIImageView(image: UIImage(named: "tp_tips_image"))
        view.addSubview(img)
        img.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(15)
            make.size.equalTo(CGSize(width: 250, height: 122))
        }
        
        let titleLab = UILabel()
        titleLab.textAlignment = .center
        titleLab.font = MediumFont(17)
        titleLab.text = "请旋转手机横拍发票"
        titleLab.textColor = UIColor(hexString: "#1D2129")
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(img.snp.bottom).offset(13)
            make.height.equalTo(24)
        }
        
        let contentLab = UILabel()
        contentLab.textAlignment = .center
        contentLab.font = Font(15)
        contentLab.text = "拍照请确保发票清晰、完整"
        contentLab.numberOfLines = 0
        contentLab.textColor = UIColor(hexString: "#4E5969")
        view.addSubview(contentLab)
        contentLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
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
        singleBtn.setTitle("开始拍照", for: .normal)
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
