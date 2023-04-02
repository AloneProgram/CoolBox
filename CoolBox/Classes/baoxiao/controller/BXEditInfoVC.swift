//
//  BXEditInfoVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/2.
//

import UIKit

class BXEditInfoVC: EViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    var type = ""
    var ids = ""
    
    init(_ type: String, ids: String ) {
        self.type = type
        self.ids = ids
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftTitle = "编辑报销单"
    }


    @IBAction func saveAction(_ sender: Any) {
        
    }
}
