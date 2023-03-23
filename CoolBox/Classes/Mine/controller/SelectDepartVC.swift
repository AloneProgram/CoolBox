//
//  SelectDepartVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/23.
//

import UIKit

class SelectDepartVC: EViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    var manager: ZJTableViewManager!
    var section = ZJTableViewSection()
    var departmentList: [DepartmentModel] = []
    
    var selectDepartBlock: ((String, String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = EColor.viewBgColor
        tableView.backgroundColor = .clear
        bottomViewHeight.constant = 48 + kBottomSpace
        
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36))
        let lab = UILabel(text: "组织架构", font: Font(14), nColor: UIColor(hexString: "#939AA3"))
        headView.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
        section.headerHeight = 36
        section.headerView = headView
        tableView.separatorStyle = .none
        manager = ZJTableViewManager(tableView: tableView)
        manager.register(ML_DepartmentCell.self, DepartmentCellItem.self)
        manager.register(ML_MemberCell.self, MemberCellItem.self)
        manager.add(section: section)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        leftTitle = "选择部门"
        
        requestDepartmentList()
    }

    func handleData() {
        //第一级固定为企业
        let item0 = DepartmentCellItem()
        item0.title = Login.currentAccount().companyName
        item0.d_Id = Login.currentAccount().companyId
        item0.pid = "0"
        item0.isExpand = true
        item0.cellHeight = 47
        item0.isSelectDepartment = true
        item0.clickSelectBtnHandler = {[weak self] id, pid, name in
            self?.selecctDepart(id: id, pid: pid, name: name)
        }
        
        section.add(item: item0)
        
        handleItems(item0, list: departmentList)
        manager.reload()
    }
    
    
    func handleItems(_ item: DepartmentCellItem, list: [DepartmentModel]) {
        list.forEach { depart in
            let subItem =  DepartmentCellItem()
            subItem.title = depart.name
            subItem.d_Id = depart.id
            subItem.isExpand = true
            subItem.cellHeight = 47
            subItem.pid = depart.parentId
            subItem.isSelectDepartment = true
            subItem.clickSelectBtnHandler = {[weak self] id, pid, name in
                self?.selecctDepart(id: id, pid: pid, name: name)
            }
            item.addSub(item: subItem, section: section)
            handleItems(subItem, list: depart.children)
        }
    }

    
    func selecctDepart(id: String, pid: String, name: String) {
        selectDepartBlock?(id, pid, name)
        popViewController()
    }
}

//MARK: Request
extension SelectDepartVC {
    func requestDepartmentList() {
        let cid = Login.currentAccount().companyId
        MineApi.requestDepartmentList(cid: cid) { [weak self] model in
            self?.departmentList = model.list
            self?.handleData()
        }
    }
}
