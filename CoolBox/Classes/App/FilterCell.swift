//
//  TextFilterCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/25.
//

import UIKit

class FilterCell: UITableViewCell {
    
    @IBOutlet weak var leftIcon: UIImageView!
    
    @IBOutlet weak var leftIconWid: NSLayoutConstraint!
    
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    
    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var rightLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func bindFilter(_ item: FIlterModel, indexPath: IndexPath) {
        rightLabel.isHidden = indexPath.section != 1
        leftIcon.isHidden = indexPath.section == 1
        leftIconWid.constant = leftIcon.isHidden ? 0 : 16
        leftMargin.constant = leftIcon.isHidden ? 0 : 8
        
        
        if indexPath.section == 1 {
            leftLabel.text = indexPath.row == 0 ? "开始" : "结束"
            rightLabel.text = item.title.length > 0 ? item.title : "选择日期"
        }else {
            leftLabel.text = item.title
        }
        
        if indexPath.section == 0 {
            leftIcon.image = item.isSelected ? UIImage(named: "ic_blue_selectcircle") : UIImage(named: "ic_blue_circle")
            
        }else if indexPath.section == 2 {
            leftIcon.image = item.isSelected ? UIImage(named: "ic_checked") : UIImage(named: "ic_unCheck")
        }
    }
}
