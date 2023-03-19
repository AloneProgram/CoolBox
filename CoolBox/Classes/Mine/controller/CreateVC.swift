//
//  CreateCompanyVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

@_exported import McPicker

enum CreateType {
    //创建组织
    case createCompany
    
    //添加部门
    case addDepart
    
    //添加成员
    case addMemeber
    
    var leftTitle: String {
        switch self {
        case .createCompany:
            return "创建组织"
        case .addDepart:
            return "添加部门"
        case .addMemeber:
            return "添加成员"
        }
    }
    
    var list: [[CommonInputModel]] {
        switch self {
        case .createCompany:
            return [
                [
                    CommonInputModel(leftText: "组织名称", tfPlaceHolder: "请输入企业名称", showBtn: true, btnTitlte: "从抬头导入"),
                    CommonInputModel(leftText: "所属行业", canInput: false, tfPlaceHolder: "请选择"),
                    CommonInputModel(leftText: "组织规模", canInput: false, tfPlaceHolder: "请选择"),
                ],
                [
                    CommonInputModel(leftText: "姓名", tfPlaceHolder: "请输入姓名", tfText: Login.currentAccount().usedNickName),
                    CommonInputModel(leftText: "手机", tfPlaceHolder: "请输入手机", tfText: Login.currentAccount().mobile, tfType: .phonePad),
                    CommonInputModel(leftText: "邮箱", tfPlaceHolder: "请输入邮箱", tfText: ""),
                ]
            ]
        case .addDepart:
            return [
                [],
                [],
            ]
        case .addMemeber:
            return [
                [],
                [],
                []
            ]
        }
    }
    
    var bottomBtnTitle: String {
        switch self {
        case .createCompany:
            return "立即创建"
        default:
            return "保存"
        }
    }
}

class CreateVC: EViewController {
    
    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomBtn: UIButton!
    
    var type: CreateType = .createCompany
    
    var list: [[CommonInputModel]] = []
    
    init(_ type: CreateType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftTitle = type.leftTitle
        view.backgroundColor = EColor.viewBgColor
        tableVIew.backgroundColor = .clear
        
        bottomViewHeight.constant = 48 + kBottomSpace
        
        list = type.list
        
        if #available(iOS 15.0, *) {
            tableVIew.sectionHeaderTopPadding = 0
        }
        tableVIew.dataSource = self
        tableVIew.delegate = self
        let nib = UINib(nibName: "CommonInputCell", bundle: nil)
        tableVIew.register(nib, forCellReuseIdentifier: "CommonInputCell")
        tableVIew.estimatedRowHeight = 54
        tableVIew.separatorStyle = .none
        tableVIew.reloadData()
        
        bottomBtn.setTitle(type.bottomBtnTitle, for: .normal)
        
        if type == .createCompany, GlobalConfigManager.shared.companyInfoConfig == nil {
            GlobalConfigManager.shared.requestCompanyInfoConfig()
        }
    }
    
    @IBAction func clickBottomBtnAction(_ sender: Any) {
        switch type {
        case .createCompany:
            createCompanyRequest()
        case .addDepart:
            saveDepart()
        case .addMemeber:
            saveMember()
        }
    }
    
    
    
}

//MARK: Request
extension CreateVC {
    func createCompanyRequest() {
        
    }
    
    func saveDepart() {
        
    }
    
    func saveMember() {
        
    }
    
    func getInvoiceTitleList() {
        MineApi.getInvoiceTitleList { list in
            if list.count > 0 {
                let picker = McPicker(data: [list])
                picker.fontSize = 16
                picker.toolbarBarTintColor = .white
                let fixedSpace = McPickerBarButtonItem.fixedSpace(width: 16)
                let flexibleSpace = McPickerBarButtonItem.flexibleSpace()
                let fireButton = McPickerBarButtonItem.done(mcPicker: picker, title: "确定") // Set custom Text
                let cancelButton = McPickerBarButtonItem.cancel(mcPicker: picker, title: "取消", barButtonSystemItem: .cancel) // or system items
                picker.setToolbarItems(items: [fixedSpace, cancelButton, flexibleSpace, fireButton, fixedSpace])
                picker.show(doneHandler: { [weak self] (selections: [Int:String]) in
                    if let name = selections[0] {
                        self?.list[0][0].tfText = name
                        self?.tableVIew.reloadData()
                    }
                })
            }else {
                EToast.showInfo("暂无抬头信息")
            }
        }
    }
}

//MARK: Action
extension CreateVC {
    func fromTitleImport() {
        getInvoiceTitleList()
    }
    
    func editInputInfo(_ text: String, indexPath: IndexPath) {
        list[indexPath.section][indexPath.row].tfText = text
        tableVIew.reloadData()
    }
    
    func selectIndustry() {
        guard let config = GlobalConfigManager.shared.companyInfoConfig else { return}
        var list: [[String]] = []
        config.industryList.forEach { industry in
            
        }
        
    }
    
    func selectStaffType() {
        guard let config = GlobalConfigManager.shared.companyInfoConfig else { return}
    }
}



extension CreateVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommonInputCell = tableView.dequeueReusableCell(withIdentifier: "CommonInputCell", for: indexPath) as! CommonInputCell
        cell.selectionStyle = .none
        cell.bindInputModel(list[indexPath.section][indexPath.row])
        cell.clickBtnBlock = { [weak self] in
            self?.fromTitleImport()
        }
        cell.textEndEditBlock = {  [weak self] text in
            self?.editInputInfo(text, indexPath: indexPath)
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case .createCompany:
            if indexPath.section == 0 {
                if indexPath.row == 1 {
                    selectIndustry()
                }else if indexPath.row == 2 {
                    selectStaffType()
                }
            }
        case .addDepart:
            break
        case .addMemeber:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var height: CGFloat = 36
        if type != .createCompany, section > 0 {
            height = 10
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: height))
        var title = ""
        if section == 0 {
            title = type == .createCompany ? "组织信息" : "基本信息"
        }else {
            title = type == .createCompany ? "联系信息" : ""
        }
        
        let lab = UILabel(text: title, font: Font(14), nColor: UIColor(hexString: "#939AA3"))
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 36
        if type != .createCompany, section > 0 {
            height = 10
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.01
    }
}
