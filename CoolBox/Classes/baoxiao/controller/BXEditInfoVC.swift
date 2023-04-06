//
//  BXEditInfoVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/2.
//

import UIKit

class BXEditInfoVC: EViewController, PresentFromBottom {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    private var list: [[Any]] = []
    
    //创建报销单
    var type = ""
    var ids = ""
    
    //编辑报销单
    var eid = ""
    
    //是否是创建报销单
    var isCreateEx = true
    
    var bxInfo: BXInfoModel?
    
    init(_ type: String = "", ids: String = "", eId: String = "" ) {
        self.type = type
        self.ids = ids
        self.eid = eId
        super.init(nibName: nil, bundle: nil)
        isCreateEx = eid.length == 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftTitle = "编辑报销单"
        
        bottomViewHeight.constant = 48 + kBottomSpace
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.backgroundColor = .clear
       
        tableView.dataSource = self
        tableView.delegate = self
        let infoNib = UINib(nibName: "CommonInfoCell", bundle: nil)
        tableView.register(infoNib, forCellReuseIdentifier: "CommonInfoCell")
        let inputNib = UINib(nibName: "CommonInputCell", bundle: nil)
        tableView.register(inputNib, forCellReuseIdentifier: "CommonInputCell")
        
        tableView.estimatedRowHeight = 56
        tableView.separatorStyle = .none
        
        
        if isCreateEx {  //创建报销单需先创建预报销单
            BXApi.createPreExpenseRequest(invoiceIds: ids, type: type) {[weak self] exId in
                self?.getPreExpeneInfo(eId: exId)
            }
        }else {
            //获取报销单信息
        }

        
        if type == "1" { //差旅费
            list = defaultTravleList()
        }else {  //费用报销
            list = defaultFeeList()
        }
    }
    
    func defaultTravleList() -> [[Any]] {
        return [
            [CommonInfoModel(leftText: "差旅费报销", rightText: "切换类型", showRightArrow: true)],
            [
                CommonInputModel(leftText: "部门", tfPlaceHolder: "请输入部门", showLine: false, bottomLineHeight: 10),
                CommonInputModel(leftText: "日期",canInput: false , tfPlaceHolder: "请选择日期",showLine: false,  bottomLineHeight: 10),
                CommonInputModel(leftText: "报销人", tfPlaceHolder: "请输入姓名",showLine: false,  bottomLineHeight: 10),
                CommonInputModel(leftText: "报销事由", tfPlaceHolder: "请输入报销事由",showLine: false,  bottomLineHeight: 10),
                CommonInputModel(showRedPoint: false,leftText: "预借旅费  ¥", tfPlaceHolder: "0.00", showLine: false,  bottomLineHeight: 10),
            ]
        ]
    }
    
    func defaultFeeList() -> [[Any]] {
        return [
            [CommonInfoModel(leftText: "费用报销", rightText: "切换类型", showRightArrow: true)],
            [
                CommonInputModel(leftText: "部门", tfPlaceHolder: "请输入部门",showLine: false,  bottomLineHeight: 10),
                CommonInputModel(leftText: "日期",canInput: false , tfPlaceHolder: "请选择日期", showLine: false,  bottomLineHeight: 10),
                CommonInputModel(leftText: "报销人", tfPlaceHolder: "请输入姓名",showLine: false,  bottomLineHeight: 10),
                CommonInputModel(leftText: "报销事由",tfPlaceHolder: "请输入报销事由", showLine: false, bottomLineHeight: 10),
                CommonInputModel(leftText: "费用类型",canInput: false , tfPlaceHolder: "请选择费用类型",showLine: false,  bottomLineHeight: 10),
            ]
        ]
    }


    @IBAction func saveAction(_ sender: Any) {
        
    }
    
    func getPreExpeneInfo(eId: String){
        BXApi.getPreExpenseInfo(eid: eId) { [weak self] info in
            self?.bxInfo = info
            if info.travelData.count > 0 {
                self?.list.append(info.travelData)
            }
            if info.invoiceData.count > 0 {
                self?.list.append(info.invoiceData)
            }
            
            (self?.list[1][0] as! CommonInputModel).tfText  = UserDefaults.standard.string(forKey: "BaoXiao_Depatement") ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "zh")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            //将选定的值转换为string格式以设定格式输出
            let dateStr = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(Double(info.createdAt) ?? 0)))
            (self?.list[1][1] as! CommonInputModel).tfText = dateStr
            (self?.list[1][2] as! CommonInputModel).tfText = info.username.length > 0 ? info.username : (UserDefaults.standard.string(forKey: "BaoXiao_Depatement") ?? "")
            (self?.list[1][4] as! CommonInputModel).tfText = GlobalConfigManager.getValue(with: info.itemType, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceItemType)
            
            self?.tableView.reloadData()
        }
    }
    
    @objc func changeTravelStandard() {
        
    }
}

extension BXEditInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: CommonInfoCell = tableView.dequeueReusableCell(withIdentifier: "CommonInfoCell", for: indexPath) as! CommonInfoCell
            cell.selectionStyle = .none
            cell.bindData(list[0][indexPath.row] as! CommonInfoModel)
            return cell
        case 1:
            let cell: CommonInputCell = tableView.dequeueReusableCell(withIdentifier: "CommonInputCell", for: indexPath) as! CommonInputCell
            cell.selectionStyle = .none
            cell.bindInputModel(list[1][indexPath.row] as! CommonInputModel)
            
            return cell
        default :
            return UITableViewCell()
        }
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            //TODO: 切换类型
        }else if indexPath.section == 1 {
            if indexPath.row == 1 {
                let result: DatePicker.DatePickerClosure = { [weak self] dateStr in
                    (self?.list[indexPath.section][indexPath.row] as! CommonInputModel).tfText = dateStr
                    tableView.reloadData()
                }
                let picker = DatePicker(.date, handle: result)
                presentFromBottom(picker)
            }else if type == "2", indexPath.row == 4 {
                guard let config = GlobalConfigManager.shared.systemoInfoConfig else { return}
                let values: [String] = config.invoidceItemType_values
                
                var tmp: [[String]] = []
                values.forEach { v in
                    tmp.append([v])
                }
                let picker = McPicker(data: [tmp])
                picker.fontSize = 16
                picker.toolbarBarTintColor = .white
                let fixedSpace = McPickerBarButtonItem.fixedSpace(width: 16)
                let flexibleSpace = McPickerBarButtonItem.flexibleSpace()
                let fireButton = McPickerBarButtonItem.done(mcPicker: picker, title: "确定") // Set custom Text
                let cancelButton = McPickerBarButtonItem.cancel(mcPicker: picker, title: "取消", barButtonSystemItem: .cancel) // or system items
                picker.setToolbarItems(items: [fixedSpace, cancelButton, flexibleSpace, fireButton, fixedSpace])
                picker.show(doneHandler: { [weak self] (selections: [Int: String]) in
                    if let text = selections.values.first {
                        (self?.list[indexPath.section][indexPath.row] as! CommonInputModel).tfText = text
                             }
                    self?.tableView.reloadData()
                })
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var text = ""
        switch section {
        case 0:    text = "报销类型"
        case 1:    text = "基本信息"
        case 2:    text = type == "1" ? "发票列表" : "差旅行程"
        case 3:    text = "其他费用"
        default:break
        }
      
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36))
        let lab = UILabel(text: text, font: SCFont(14), nColor: UIColor(hexString: "#939AA3"))
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        
        if type == "2", section == 2 {
            let btn = UIButton(type: .custom)
            btn.setTitle("修改出差补贴标准", for: .normal)
            btn.titleLabel?.font = Font(14)
            btn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
            btn.addTarget(self, action: #selector(changeTravelStandard), for: .touchUpInside)
            view.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(-15)
            }
        }
            
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.01
    }
}
