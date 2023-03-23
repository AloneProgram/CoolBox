//
//  ImportEntranceView.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/23.
//

import UIKit

class ImportEntranceView: UIView {
    
    
    var importActionBlock: ((Int) -> Void)?
    
    class func instance() -> ImportEntranceView {
        return UINib(nibName: "ImportEntranceView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ImportEntranceView
    }

    override func awakeFromNib() {}
    

    @IBAction func importActipn(_ sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag ?? -1
        importActionBlock?(tag)
        
    }
    
}
