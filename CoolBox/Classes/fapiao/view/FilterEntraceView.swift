//
//  FilterEntraceView.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/25.
//

import UIKit

class FilterEntraceView: UIView {
    
    
    @IBOutlet weak var filterBtn: UIButton!
    
    var clickBlock: (() -> Void)?
    
    class func instance() -> FilterEntraceView {
        return UINib(nibName: "FilterEntraceView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! FilterEntraceView
    }

    override func awakeFromNib() {}
    
    @IBAction func filterAction(_ sender: Any) {
        clickBlock?()
    }
    
}
