//
//  CreateCompanyVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

enum CreateType {
    //创建组织
    case createCompany
    
    //添加部门
    case addDepart
    
    //添加成员
    case addMemeber
}

class CreateVC: EViewController {
    
    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var bottimViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }



}
