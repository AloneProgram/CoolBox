//
//  MemberListVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/22.
//

import UIKit

class MemberListVC: EViewController {
    
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var botomViewHeight: NSLayoutConstraint!
    
    var bottomContentView = BaseHeightBottomView.instance()
    
    var departmentList: [DepartmentModel] = []
    var memberList: [MemberModel] = []
    
    var isMemberList = true
    
    var manager: ZJTableViewManager!
    var section = ZJTableViewSection()
    
    
    init(isMemberList: Bool = true) {
        self.isMemberList = isMemberList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestDepartmentList()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchView.isHidden = isMemberList
        searchViewHeight.constant = searchView.isHidden ? 0 : 68

        view.backgroundColor = EColor.viewBgColor
        tableView.backgroundColor = .clear
        
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36))
        let lab = UILabel(text: "组织架构", font: Font(14), nColor: UIColor(hexString: "#939AA3"))
        headView.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
        section.headerView = headView
        section.headerHeight = 36
        tableView.separatorStyle = .none
        manager = ZJTableViewManager(tableView: tableView)
        manager.register(ML_DepartmentCell.self, DepartmentCellItem.self)
        manager.register(ML_MemberCell.self, MemberCellItem.self)

        manager.add(section: section)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        
        leftTitle = isMemberList ? "添加成员" : "选择审批人"
        botomViewHeight.constant = 76 + kBottomSpace
        
        bottomContentView.bottomType = .addMember
        bottomContentView.leftBlock = { [weak self] in
            self?.push(CreateVC(.addDepart))
        }
        bottomContentView.rightBlock = { [weak self] in
            self?.push(CreateVC(.addMemeber))
        }
        bottomView.addSubview(bottomContentView)
        bottomContentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(76)
        }
    }
    
    func handleData(_ memberList: [MemberModel]) {
        
        section.removeAllItems()
        
        //第一级固定为企业
        let item0 = DepartmentCellItem()
        item0.title = memberList.first?.departmentName ?? ""
        item0.d_Id = memberList.first?.departmentId ?? ""
        item0.isExpand = true
        item0.cellHeight = 47
        section.add(item: item0)
        memberList.filter({$0.departmentId == item0.d_Id}).forEach { member in
            let memberItem = MemberCellItem()
            memberItem.title = member.name
            memberItem.type = member.type
            memberItem.id = member.id
            memberItem.status = member.status
            memberItem.isSelectShenpi = false
            memberItem.isBeSelectd = false
            memberItem.cellHeight = 54
            item0.addSub(item: memberItem, section: section)
        }
        
        handleItems(item0, list: departmentList, memberList: memberList)
        manager.reload()
    }
    
    
    func handleItems(_ item: DepartmentCellItem, list: [DepartmentModel], memberList: [MemberModel]) {
        list.forEach { depart in
            let subItem =  DepartmentCellItem()
            subItem.title = depart.name
            subItem.d_Id = depart.id
            subItem.isExpand = true
            subItem.cellHeight = 47
            item.addSub(item: subItem, section: section)
            memberList.filter({$0.departmentId == depart.id}).forEach { member in
                let memberItem = MemberCellItem()
                memberItem.title = member.name
                memberItem.type = member.type
                memberItem.id = member.id
                memberItem.status = member.status
                memberItem.isSelectShenpi = false
                memberItem.isBeSelectd = false
                memberItem.cellHeight = 54
                subItem.addSub(item: memberItem, section: section)
            }
            
            handleItems(subItem, list: depart.children, memberList: memberList)
        }
    }
}


//MARK: Request
extension MemberListVC {
    func requestDepartmentList() {
        departmentList = []
        memberList = []
        
        let cid = Login.currentAccount().companyId
        MineApi.requestDepartmentList(cid: cid) { [weak self] model in
            self?.departmentList = model.list
            self?.requestMemberList()
        }
    }
    
    func requestMemberList() {
        let cid = Login.currentAccount().companyId
        MineApi.requestMemeberList(cid: cid, result: { [weak self] model in
            self?.memberList = model.list
            self?.handleData(model.list)
        })
    }
}
