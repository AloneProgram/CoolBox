//
//  CommonInputCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

class CommonInputCell: UITableViewCell {
    
    @IBOutlet weak var redPointLabel: UILabel!
    
    @IBOutlet weak var textfield: UITextField!
    
    @IBOutlet weak var leftTitleLabel: UILabel!
    
    @IBOutlet weak var actionBtn: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnAction(_ sender: Any) {
        
    }
}
