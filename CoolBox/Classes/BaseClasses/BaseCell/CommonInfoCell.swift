//
//  CommonInfoCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/18.
//

import UIKit

class CommonInfoCell: UITableViewCell {
    
    @IBOutlet weak var leftViewWid: NSLayoutConstraint!
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var leftTitle: UILabel!
    
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var rightTltle: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var rightVIewWid: NSLayoutConstraint!
    
    @IBOutlet weak var rightPaddingLabel: PaddingLabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(_ model: CommonInfoModel) {
        leftView.isHidden = model.leftLcon == nil
        leftViewWid.constant = leftView.isHidden ? 0 : 32
        leftIcon.image = model.leftLcon
        leftTitle.text = model.leftText
        
        rightTltle.text = model.rightText
        rightImageView.isHidden = !model.showRightImageView
        if let urlStr = model.rightImageUrl  {
            rightImageView.kf.setImage(with: URL(string: urlStr))
        }
        
        rightView.isHidden = !model.showRightArrow
        rightVIewWid.constant = rightView.isHidden ? 0 : 32
        
        rightPaddingLabel.isHidden = true
    }
    
    func bindCompay(_ commpany: CompanyModel) {
        leftView.isHidden = true
        leftViewWid.constant = 0
        leftTitle.text = commpany.companyName
        rightImageView.isHidden = true
        
        rightPaddingLabel.isHidden = !commpany.isDefault
        rightTltle.isHidden = commpany.isDefault
        
        rightView.isHidden = commpany.isDefault
        rightVIewWid.constant = rightView.isHidden ? 0 : 32
        
        if commpany.isDefault {
            rightPaddingLabel.style = .blue
            rightPaddingLabel.text = "当前企业"
        }else {
            rightTltle.text = "点击切换"
        }
        
        
    }
    
}
