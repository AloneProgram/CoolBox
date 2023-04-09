//
//  SPProcessCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/9.
//

import UIKit

class SPProcessCell: UITableViewCell {
    
    @IBOutlet weak var cricleLabel: UILabel!
    
    @IBOutlet weak var lineLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var inviteBtn: UIButton!
    
    @IBOutlet weak var changeBtn: UIButton!
    
    @IBOutlet weak var addUserBtn: UIButton!
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var remarkLabel: UILabel!
    
    var clickAddUser:(() -> Void)?
    var clickChangeUser:(() -> Void)?
    var clickInviteUser:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func inviteAction(_ sender: Any) {
        clickInviteUser?()
    }
    
    
    @IBAction func chjangeAction(_ sender: Any) {
        clickChangeUser?()
    }
    
    @IBAction func addUserAction(_ sender: Any) {
        clickAddUser?()
    }
    
    func bindData(process: ProcessModel, isCrerateSP: Bool, isLastLine: Bool, isFirst: Bool) {
        titleLabel.text = process.nodeName
        dateLabel.text = process.time == "0" ? "" : process.time
        if process.status == .sping {
            inviteBtn.isHidden = process.invitationUrl.length == 0
        }else {
            inviteBtn.isHidden = true
        }
        
        userLabel.text = process.name
        remarkLabel.text = process.reason.length > 0 ? "\"\(process.reason ?? "")\"" : ""
        
        lineLabel.backgroundColor = process.nextStatus.lineColor
        if isCrerateSP {
            cricleLabel.borderColor = UIColor(hexString: "#165DFF")
        }else {
            if isFirst {
                cricleLabel.borderColor = UIColor(hexString: "#165DFF")
            }else {
                cricleLabel.borderColor = process.status.lineColor
            }
        }
        
        lineLabel.isHidden = isLastLine
        
        cricleLabel.backgroundColor = .white
        
        if process.status == .refused {
            cricleLabel.backgroundColor = process.status.statusTextColor
        }else if process.status == .sping {
            cricleLabel.backgroundColor = UIColor(hexString: "#165DFF")
        }
        
        statusLabel.text = process.status.statusStr
        statusLabel.textColor = process.status.statusTextColor
        
        changeBtn.isHidden = true
        addUserBtn.isHidden = true
        if isCrerateSP, process.name.length > 0 {
            changeBtn.isHidden = false
        }
        if isCrerateSP, process.name.length == 0 {
            addUserBtn.isHidden = false
        }
        
    }
}
