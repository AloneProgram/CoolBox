//
//  FPViewController.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/15.
//

import UIKit

class FPViewController: EViewController {
    
    private var headerView = ImportEntranceView.instance()

    override var navigationBarStyle: NavigationBarStyle { return .transparentBackground }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EColor.viewBgColor
        self.bigLeftTitle = "导入发票"
        
        headerView.importActionBlock = { [weak self] tag in
            self?.importAction(tag)
        }
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kNaviBarHeight)
            make.height.equalTo(140)
        }
    }
    
    func importAction(_ tag: Int) {
        switch tag {
        case 0: scanImport()
        case 1: wxImport()
        case 2: aliImprot()
        case 3: tabkeImport()
        case 4: emailImport()
        default:break
        }
    }
}

extension FPViewController {
    
    func scanImport() {
        
    }
    
    func wxImport(){
        
    }
    
    func aliImprot() {
        
    }
    
    func tabkeImport() {
        
    }
    
    func emailImport() {
        
    }
}
