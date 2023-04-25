//
//  BXEditInfoVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/2.
//

import UIKit

class BXEditInfoVC: EViewController, PresentFromBottom, PresentToCenter {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    private var list: [[Any]] = []
    
    //1: 差旅费报销; 2: 费用报销
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
        let fpNib = UINib(nibName: "BXFapiaoCell", bundle: nil)
        tableView.register(fpNib, forCellReuseIdentifier: "BXFapiaoCell")
        
        let trNib = UINib(nibName: "TravelOtherFeeCell", bundle: nil)
        tableView.register(trNib, forCellReuseIdentifier: "TravelOtherFeeCell")
        
        tableView.estimatedRowHeight = 56
        tableView.separatorStyle = .none
        
        
        if isCreateEx {  //创建报销单需先创建预报销单
            BXApi.createPreExpenseRequest(invoiceIds: ids, type: type) {[weak self] exId in
                self?.getPreExpeneInfo(eId: exId)
            }
        }else {
            //获取报销单信息
            getExpeneInfo(eId: eid)
        }

    }
    
    func defaultTravleList() -> [[Any]] {
        let date = Date()//获取选定的值
        //初始化日期格式化对象
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        //将选定的值转换为string格式以设定格式输出
        let dateStr = dateFormatter.string(from: date)
        return [
            [CommonInfoModel(leftText: "差旅费报销", rightText: "切换类型", showRightArrow: true)],
            [
                CommonInputModel(leftText: "部门", tfPlaceHolder: "请输入部门", showLine: false, bottomLineHeight: 10),
                CommonInputModel(leftText: "日期",canInput: false , tfPlaceHolder: "请选择日期", tfText: dateStr,showLine: false,  bottomLineHeight: 10),
                CommonInputModel(leftText: "报销人", tfPlaceHolder: "请输入姓名",showLine: false,  bottomLineHeight: 10),
                CommonInputModel(leftText: "报销事由", tfPlaceHolder: "请输入报销事由",showLine: false,  bottomLineHeight: 10),
                CommonInputModel(showRedPoint: false,leftText: "预借旅费  ¥", tfPlaceHolder: "0.00", showLine: false,  bottomLineHeight: 10),
            ]
        ]
    }
    
    func defaultFeeList() -> [[Any]] {
        let date = Date()//获取选定的值
        //初始化日期格式化对象
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        //将选定的值转换为string格式以设定格式输出
        let dateStr = dateFormatter.string(from: date)
        return [
            [CommonInfoModel(leftText: "费用报销", rightText: "切换类型", showRightArrow: true)],
            [
                CommonInputModel(leftText: "部门", tfPlaceHolder: "请输入部门",showLine: false,  bottomLineHeight: 10),
                CommonInputModel(leftText: "日期",canInput: false, tfPlaceHolder: "请选择日期", tfText: dateStr, showLine: false,  bottomLineHeight: 10),
                CommonInputModel(leftText: "报销人", tfPlaceHolder: "请输入姓名",showLine: false,  bottomLineHeight: 10),
                CommonInputModel(leftText: "报销事由",tfPlaceHolder: "请输入报销事由", showLine: false, bottomLineHeight: 10),
                CommonInputModel(leftText: "费用类型",canInput: false , tfPlaceHolder: "请选择费用类型",showLine: false,  bottomLineHeight: 10),
            ]
        ]
    }


    @IBAction func saveAction(_ sender: Any) {
        setExInfo()
    }
    
    
    @objc func changeTravelStandard() {
        push(ChangeSubsidyStandardVC())
    }
    
    @objc func createTravel() {
        guard let info = bxInfo else {return}
        let vc = CreteTravelVC(isPre: isCreateEx, eid: info.id)
        vc.createTravleBlock = { [weak self] in
            if let isCreateEx = self?.isCreateEx, isCreateEx {
                self?.getPreExpeneInfo(eId: info.id, reloadTravle: true)
            }else {
                self?.getExpeneInfo(eId: info.id, reloadTravle: true)
            }
        }
        push(vc)
    }
    
    func editTravel(index: Int, travle: TravleData) {
        guard let info = bxInfo else {return}
        let vc = CreteTravelVC(isPre: isCreateEx, eid: info.id, travel: travle)
        vc.createTravleBlock = { [weak self]  in
            if let isCreateEx = self?.isCreateEx, isCreateEx {
                self?.getPreExpeneInfo(eId: info.id, reloadTravle: true)
            }else {
                self?.getExpeneInfo(eId: info.id, reloadTravle: true)
            }
        }
        push(vc)
    }
}

// request
extension BXEditInfoVC {
    
    func getPreExpeneInfo(eId: String, reloadTravle: Bool = false){
        BXApi.getPreExpenseInfo(eid: eId) { [weak self] info in
            self?.bxInfo = info
            self?.type = info.type
            if reloadTravle {
                self?.list[2] = info.travelData
                self?.tableView.reloadData()
                return
            }
            
            
            if info.type == "1" { //差旅费
                self?.list = self?.defaultTravleList() ?? []
            }else {  //费用报销
                self?.list = self?.defaultFeeList() ?? []
            }

            if info.type == "1" {
                self?.list.append(info.travelData)
            }
            if info.invoiceData.count > 0 {
                self?.list.append(info.invoiceData)
            }
            
            let date = Date()//获取选定的值
            //初始化日期格式化对象
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "zh")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            //将选定的值转换为string格式以设定格式输出
            let dateStr = dateFormatter.string(from: date)
            
            (self?.list[1][0] as! CommonInputModel).tfText  = info.department.length > 0 ? info.department : (UserDefaults.standard.string(forKey: "BaoXiao_Depatement") ?? "")

            (self?.list[1][1] as! CommonInputModel).tfText = info.date == "0" ? dateStr : info.date
            (self?.list[1][2] as! CommonInputModel).tfText = info.username.length > 0 ? info.username : (UserDefaults.standard.string(forKey: "BaoXiao_Username") ?? "")
            (self?.list[1][3] as! CommonInputModel).tfText = info.reason
            if info.type == "1" {
                (self?.list[1][4] as! CommonInputModel).tfText = info.preGetFee
            }else {
                (self?.list[1][4] as! CommonInputModel).tfText = GlobalConfigManager.getValue(with: info.itemType, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceItemType)
            }
           
            
            self?.tableView.reloadData()
        }
    }
    
    func deleteExpenseFP(fpId: String){
        guard let info = bxInfo else {return}
        BXApi.deleteExpenseFP(isPre: isCreateEx, fpid: fpId, eid: info.id) { [weak self] _ in
            if self?.type == "2" {
                var list = self?.list[2]
                list?.removeAll(where: {($0 as! InvoiceData).list.first?.id == fpId})
                self?.list[2] = list ?? []
                self?.tableView.reloadData()
            }
        }
    }
    
    func setExInfo() {
        guard let info = bxInfo else {return}
        var params: [String: String] = [:]
        if type == "1" {
            params = ["date": (list[1][1] as! CommonInputModel).tfText,
                      "reason": (list[1][3] as! CommonInputModel).tfText,
                      "type":"1",
                      "department": (list[1][0] as! CommonInputModel).tfText ,
                      "expense_id": info.id,
                      "pre_get_fee": (list[1][4] as! CommonInputModel).tfText,
                      "username":  (list[1][2] as! CommonInputModel).tfText
            ]
           
        }else {
            params = ["date": (list[1][1] as! CommonInputModel).tfText,
                      "reason": (list[1][3] as! CommonInputModel).tfText,
                      "item_type": GlobalConfigManager.getKey(with: (list[1][4] as! CommonInputModel).tfText, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceItemType),
                      "type":"2",
                      "department": (list[1][0] as! CommonInputModel).tfText ,
                      "expense_id": info.id,
                      "username":  (list[1][2] as! CommonInputModel).tfText
            ]
        }
        
        UserDefaults.standard.set((list[1][0] as! CommonInputModel).tfText, forKey: "BaoXiao_Depatement")
        UserDefaults.standard.set((list[1][2] as! CommonInputModel).tfText, forKey: "BaoXiao_Username")
        
        BXApi.setExpenseInfo(isPre: isCreateEx, params: params) { [weak self]_ in
            if let isCreateEx = self?.isCreateEx, isCreateEx {  //预报销单点击保存需要生成报销单
                self?.createEXpense()
            }else {
                self?.deleteFile()
                self?.popViewController()
            }
        }
        
    }
    
    func deleteFile() {
        guard let info = bxInfo else {return}
        BXApi.deletePDFFile(eid: info.id)
    }
    
    func createEXpense() {
        guard let info = bxInfo else {return}
        BXApi.createExpenseRequest(eid: info.id) {[weak self] eid in
            self?.removeCurrentAndPush(viewController: BXDetailInfoVC(eid: eid))
        }
    }
    
    func getExpeneInfo(eId: String, reloadTravle: Bool = false){
        BXApi.getExpenseInfo(eid: eId) { [weak self] info in
            self?.bxInfo = info
            self?.type = info.type
            
            if reloadTravle {
                self?.list[2] = info.travelData
                self?.tableView.reloadData()
                return
            }
            
            if info.type == "1" { //差旅费
                self?.list = self?.defaultTravleList() ?? []
            }else {  //费用报销
                self?.list = self?.defaultFeeList() ?? []
            }
            
            if info.type == "1" {
                self?.list.append(info.travelData)
            }
            if info.invoiceData.count > 0 {
                self?.list.append(info.invoiceData)
            }
            
            let date = Date()//获取选定的值
            //初始化日期格式化对象
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "zh")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            //将选定的值转换为string格式以设定格式输出
            let dateStr = dateFormatter.string(from: date)
            
            (self?.list[1][0] as! CommonInputModel).tfText  = UserDefaults.standard.string(forKey: "BaoXiao_Depatement") ?? ""
            (self?.list[1][1] as! CommonInputModel).tfText = info.date == "0" ? dateStr : info.date
            (self?.list[1][2] as! CommonInputModel).tfText = info.username.length > 0 ? info.username : (UserDefaults.standard.string(forKey: "BaoXiao_Username") ?? "")
            (self?.list[1][3] as! CommonInputModel).tfText = info.reason
            if info.type == "1" {
                (self?.list[1][4] as! CommonInputModel).tfText = info.preGetFee
            }else {
                (self?.list[1][4] as! CommonInputModel).tfText = GlobalConfigManager.getValue(with: info.itemType, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceItemType)
            }
            
            self?.tableView.reloadData()
        }
    }
    
    
    func deleteTravle(tId: String){
        guard let info = bxInfo else {return}
        BXApi.deleteTravel(isPre: isCreateEx, tid: tId, eid: info.id) { [weak self] _ in
            var tmp: [TravleData] = self?.list[2] as! [TravleData]
            tmp.removeAll(where: {$0.id == tId})
            self?.list[2] = tmp
            self?.tableView.reloadData()
        }
    }
    
    func changetTypeAlert() {
        let alert = SelectAlert(alertTitle: "选择报销类型")
        let cancel = SelectAlertAction(title: "取消", type: .cancel)

       
        let travleBX = SelectAlertAction(title: "差旅费报销") { [weak self] in
            self?.type = "1"
            self?.handleChangeType()
        }
        let feeBX = SelectAlertAction(title: "费用报销") { [weak self] in
            self?.type = "2"
            self?.handleChangeType()
        }
        
        alert.addAction(travleBX)
        alert.addAction(feeBX)
        alert.addAction(cancel)
        alert.show()
    }
    
    //修改报销单类型: 1. 预报销单先重新生成报销单再获取预报销单信息;  2.报销单: 先删除报销单再重新生预报销单,再生成报销单
    func handleChangeType() {
        guard let info = bxInfo else { return }
        if isCreateEx {
            var ids = ""
            if let arr = info.invoiceData as? [FapiaoDetailModel] {
                arr.forEach { fp in
                    ids += "\(fp.id),"
                }
            }else if let arr = info.invoiceData as? [InvoiceData] {
                arr.forEach { tmp in
                    tmp.list.forEach { fp in
                        ids += "\(fp.id),"
                    }
                }
            }

            if ids.hasSuffix(",") {
                ids = ids.subString(start: 0, length: ids.length - 1)
            }
            
            BXApi.createPreExpenseRequest(invoiceIds: ids, type: type) {[weak self] exId in
                self?.getPreExpeneInfo(eId: exId)
            }
        }else {
           
            BXApi.deleteBX(eid: info.id) {[weak self] _ in
                var ids = ""
                if self?.type == "2" {
                    (info.invoiceData as! [FapiaoDetailModel]).forEach { fp in
                        ids += "\(fp.id),"
                    }
                }else {
                    (info.invoiceData as! [InvoiceData]).forEach { tmp in
                        tmp.list.forEach { fp in
                            ids += "\(fp.id),"
                        }
                    }
                }
                if ids.hasSuffix(",") {
                    ids = ids.subString(start: 0, length: ids.length - 1)
                }
                
                BXApi.createPreExpenseRequest(invoiceIds: ids, type: self?.type ?? "") {[weak self] exId in
                    self?.getPreExpeneInfo(eId: exId)
                    self?.isCreateEx = true
                }
            }
        }
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
            cell.textEndEditBlock = { [weak self]text in
                (self?.list[indexPath.section][indexPath.row] as! CommonInputModel).tfText = text
            }
            return cell
        case 2:
            if type == "2" {
                let cell: BXFapiaoCell = tableView.dequeueReusableCell(withIdentifier: "BXFapiaoCell", for: indexPath) as! BXFapiaoCell
                cell.selectionStyle = .none
                cell.bindInvoiceData(list[2][indexPath.row] as! FapiaoDetailModel)
                return cell
            }else {
                let cell: BXFapiaoCell = tableView.dequeueReusableCell(withIdentifier: "BXFapiaoCell", for: indexPath) as! BXFapiaoCell
                cell.selectionStyle = .none
                cell.bindTravel(list[2][indexPath.row] as! TravleData)
                return cell
            }
        case 3:
            let cell: TravelOtherFeeCell = tableView.dequeueReusableCell(withIdentifier: "TravelOtherFeeCell", for: indexPath) as! TravelOtherFeeCell
            cell.selectionStyle = .none
            cell.bindInvoice(list[3][indexPath.row] as! InvoiceData)
            cell.tapBlock = { [weak self] in
                guard var invoice = self?.list[3][indexPath.row] as? InvoiceData else {
                    return
                }
                invoice.isExapnded = !invoice.isExapnded
                self?.list[3][indexPath.row] = invoice
                tableView.reloadData()
            }
            cell.clickFPBlock = { [weak self] fpId in
                self?.push(FPEditInfoVC(fpId))
            }
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
            let alert = CustomAlert(title: "系统提示", content: "切换类型后,已填写的内容将会丢失,是否确认切换?", cancleTitle: "取消", confirmTitle: "确定", confirm:  { [weak self] in
                self?.changetTypeAlert()
            })
            
            presentToCenter(alert)
            
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
        }else if indexPath.section == 2 {
            if let travel = list[indexPath.section][indexPath.row] as? TravleData {
                editTravel(index: indexPath.row, travle: travel)
            }else if let tmp = list[indexPath.section][indexPath.row] as? InvoiceData,  let fp = tmp.list.first {
                push(FPEditInfoVC(fp.id))
            }else if let fp = list[indexPath.section][indexPath.row] as? FapiaoDetailModel {
                push(FPEditInfoVC(fp.id))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var text = ""
        switch section {
        case 0:    text = "报销类型"
        case 1:    text = "基本信息"
        case 2:    text = type == "2" ? "发票列表" : "差旅行程"
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
        
        if type == "1", section == 2 {
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
        var height: CGFloat = 0
        if  type == "1", section == 2 {
            height = 40
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: height))
        if type == "1", section == 2 {
            let btn = UIButton(type: .custom)
            btn.setTitle("添加行程", for: .normal)
            btn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
            btn.titleLabel?.font = Font(14)
            btn.addTarget(self, action: #selector(createTravel), for: .touchUpInside)
            view.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height: CGFloat = 0.01
        if  type == "1", section == 2 {
            height = 40
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] (action, view, completion) in
            if self?.type == "2" {
                guard let fp = (self?.list[indexPath.section][indexPath.row] as! InvoiceData).list.first else { return }
                //删除发票
                self?.deleteExpenseFP(fpId: fp.id)
            }else {
                guard let travel = self?.list[indexPath.section][indexPath.row] as? TravleData else { return }
                //删除行程
                self?.deleteTravle(tId: travel.id)
            }
            
            completion(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 2
    }
}
