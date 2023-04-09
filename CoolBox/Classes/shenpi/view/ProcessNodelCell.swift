//
//  ProcessNodelCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/9.
//

import UIKit

class ProcessNodelCell: UITableViewCell {
    
    @IBOutlet weak var nodeName: UILabel!
    
    @IBOutlet weak var addNodebtn: UIButton!
    
    @IBOutlet weak var infpuTF: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    var saveNodeBlock: ((String) -> Void)?
    var addNodeBlock: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindNode(node: Process, isLast: Bool) {
        infpuTF.text = nil
        addNodebtn.isHidden = isLast
        
        nodeName.text = node.nodeName
        
        addNodebtn.isSelected = node.isAdd
        
        bottomView.isHidden = !node.isAdd
        bottomViewHeight.constant = bottomView.isHidden ? 0 : 54
        
    }
    
    @IBAction func addNodeAction(_ sender: Any) {
        addNodebtn.isSelected = !addNodebtn.isSelected
        
        addNodeBlock?(addNodebtn.isSelected )
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let text = infpuTF.text, text.length > 0 {
            saveNodeBlock?(text)
        }else {
            EToast.showFailed("节点名不可为空")
        }
    }
    
}
