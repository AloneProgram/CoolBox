//
//  ML_DepartmentCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/22.
//

import UIKit

class DepartmentCellItem: ZJExpandTreeCellItem {
    var title: String?
    var d_Id = "0"
    var isSelectDepartment = false
}


class ML_DepartmentCell: UITableViewCell, ZJCellProtocol {
    
    @IBOutlet weak var arrowIcon: UIImageView!
    
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var selectBtn: UIButton!
    
    var item: DepartmentCellItem!

    typealias ZJCellItemClass = DepartmentCellItem

    func cellPrepared() {
        selectBtn.isHidden = !item.isSelectDepartment
        nameLabel.text = item.title
        arrowIcon.image = item.isExpand ? UIImage(named: "icon_expanded") : UIImage(named: "ic_unExpanded")
        leftMargin.constant = CGFloat(32 * item.level)
        item.didExpand = {[weak self] i in
            self?.arrowIcon.image = i.isExpand ? UIImage(named: "icon_expanded") : UIImage(named: "ic_unExpanded")
        }
    }

    func cellDidAppear() {}

    func cellDidDisappear() {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectAction(_ sender: Any) {
        
    }
    
}
