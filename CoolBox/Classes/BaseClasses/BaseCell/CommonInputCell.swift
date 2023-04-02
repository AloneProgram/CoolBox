//
//  CommonInputCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

class CommonInputCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var redPointLabel: UILabel!
    
    @IBOutlet weak var textfield: UITextField!
    
    @IBOutlet weak var leftTitleLabel: UILabel!
    
    @IBOutlet weak var actionBtn: UIButton!
        
    @IBOutlet weak var toBtnMargin: NSLayoutConstraint!
    
    @IBOutlet weak var btnWid: NSLayoutConstraint!
    
    var lineLabe = UILabel()
    
    var clickBtnBlock: (() -> Void)?
    var textEndEditBlock: ((String) -> Void)?
    
    var hasBtn = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textfield.delegate = self
        
        lineLabe.backgroundColor = EColor.lineColor
        contentView.addSubview(lineLabe)
        lineLabe.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.left.equalTo(16)
            make.height.equalTo(0.5)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnAction(_ sender: Any) {
        clickBtnBlock?()
    }
    
    func bindInputModel(_ inputModel: CommonInputModel) {
        textfield.resignFirstResponder()
        
        hasBtn = inputModel.showBtn
        redPointLabel.isHidden = !inputModel.showRedPoint
        leftTitleLabel.text = inputModel.leftText
        textfield.placeholder = inputModel.tfPlaceHolder
        textfield.text = inputModel.tfText
        
        actionBtn.isHidden = !inputModel.showBtn
        actionBtn.setTitle(inputModel.btnTitlte, for: .normal)
        actionBtn.sizeToFit()
        btnWid.constant = inputModel.btnTitlte.widthWithConstrainedHeight(height: 20, font: Font(14)) + 5
        toBtnMargin.constant = actionBtn.isHidden ? 0 : 15
        
        lineLabe.isHidden = !inputModel.showLine
        
        textfield.isUserInteractionEnabled = inputModel.canInput
    }
    
    
    func bindTemplet(t: Template) {
        textfield.resignFirstResponder()
        hasBtn = false
        redPointLabel.isHidden  = t.required != "1"
        leftTitleLabel.text = t.name
        textfield.placeholder = "请输入\(t.name)"
        textfield.text = t.value
        
        actionBtn.isHidden = true

        toBtnMargin.constant = 0
        btnWid.constant = 0
        lineLabe.isHidden = true
        
        textfield.isUserInteractionEnabled = t.type == "text"
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        if let text = textField.text {
            textEndEditBlock?(text)
        }
    }
}
