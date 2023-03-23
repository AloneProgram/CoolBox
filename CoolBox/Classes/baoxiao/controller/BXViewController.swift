//
//  BXViewController.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/15.
//

import UIKit

class BXViewController: EViewController {

    override var navigationBarStyle: NavigationBarStyle { return .transparentBackground }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EColor.viewBgColor
        self.bigLeftTitle = "报销单列表"
        
    }
}
