//
//  BaseCollectionSegmentVC.swift
//  huandian
//
//  Created by Jhin on 2020/10/10.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

enum TabNavAdaptEvent {
    case unkown
    case fapiao
    case baoxiao
    case shenpi
    
    var canRefresh: Bool {
        return true
    }
    
    var titleArr: [String] {
        switch self {
        case .fapiao: return ["未报销", "报销中", "已报销", "无需报销"]
        case .baoxiao: return ["未审批", "审批中", "已通过", "已拒绝"]
        case .shenpi: return ["待审批", "已审批", "已发起"]
        default: return []
        }
    }
}
protocol TabNavAdaptEventProtocol {
    var eventType: TabNavAdaptEvent {get}
}

class BaseCollectionSegmentVC: BaseSegementSubVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
