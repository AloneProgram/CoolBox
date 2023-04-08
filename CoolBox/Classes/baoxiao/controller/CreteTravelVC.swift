//
//  CreteTravelVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/8.
//

import UIKit

class CreteTravelVC: EViewController, PresentFromBottom {
    
    
    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var bottomViewhHeight: NSLayoutConstraint!
    
    var list: [CommonInputModel] = [
        CommonInputModel(leftText: "出发时间", canInput: false, tfPlaceHolder: "请输入日期", showLine: false,  bottomLineHeight: 10),
        CommonInputModel(leftText: "到达时间", canInput: false , tfPlaceHolder: "请选择日期", showLine: false,  bottomLineHeight: 10),
        CommonInputModel(leftText: "出发地点", tfPlaceHolder: "请输入出发地点",showLine: false,  bottomLineHeight: 10),
        CommonInputModel(leftText: "到达地点", tfPlaceHolder: "请输入到达地点", showLine: false, bottomLineHeight: 10),
        CommonInputModel(leftText: "交通工具", canInput: false , tfPlaceHolder: "请选择交通工具",showLine: false,  bottomLineHeight: 10),
    ]
    
    var isPre: Bool = true
    var travel: TravleData?
    var eid = ""
    
    //编辑过差补天数或差补金额, isEdit就为true
    var isEdit = false
    
    var createTravleBlock:(() -> Void)?
    
    init(isPre: Bool, eid: String, travel: TravleData? = nil){
        self.isPre = isPre
        self.eid = eid
        self.travel = travel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftTitle = "编辑行程"
        
        bottomViewhHeight.constant = 48 + kBottomSpace
        
        if #available(iOS 15.0, *) {
            tableVIew.sectionHeaderTopPadding = 0
        }
        tableVIew.backgroundColor = .clear
       
        tableVIew.dataSource = self
        tableVIew.delegate = self

        let inputNib = UINib(nibName: "CommonInputCell", bundle: nil)
        tableVIew.register(inputNib, forCellReuseIdentifier: "CommonInputCell")
        
        tableVIew.estimatedRowHeight = 56
        tableVIew.separatorStyle = .none
        
        if let travle = travel {
            list.append(CommonInputModel(showRedPoint: false, leftText: "差补天数", tfPlaceHolder: "请输入差补天数",showLine: false,  bottomLineHeight: 10))
            list.append(CommonInputModel(showRedPoint: false, leftText: "差补金额", tfPlaceHolder: "请输入差补金额",showLine: false,  bottomLineHeight: 10))

            list[0].tfText =  travle.startTime
            list[1].tfText =  travle.endTime
            list[2].tfText =  travle.startLocation
            list[3].tfText =  travle.endLocation
            list[4].tfText =  GlobalConfigManager.getValue(with: travle.vehicleType, in: GlobalConfigManager.shared.systemoInfoConfig?.expenseVehicleType ?? [:])
            list[5].tfText = travle.subsidyDay
            list[6].tfText = travle.subsidyFee
        }
        
        tableVIew.reloadData()
    }

    @IBAction func commitAction(_ sender: Any) {
        
        if travel == nil {
            createTravel()
        }else {
            setTravelInfo()
        }
    }
    
    func createTravel() {
        let params: [String: String] = [
            "start_time": list[0].tfText,
            "end_time":  list[1].tfText,
            "start_location": list[2].tfText,
            "end_location": list[3].tfText,
            "vehicle_type":  GlobalConfigManager.getKey(with: list[4].tfText, in: GlobalConfigManager.shared.systemoInfoConfig?.expenseVehicleType ?? [:]),
            "is_edit":"0",
            "expense_id": eid,
            "subsidy_day":"",
            "subsidy_fee":""
        ]
        
        BXApi.createTravel(isPre: isPre, params: params) { [weak self] tid in
            self?.createTravleBlock?()
            self?.popViewController()
        }
    }
    
    func setTravelInfo() {
        let params: [String: String] = [
            "start_time": list[0].tfText,
            "end_time":  list[1].tfText,
            "start_location": list[2].tfText,
            "end_location": list[3].tfText,
            "vehicle_type":  GlobalConfigManager.getKey(with: list[4].tfText, in: GlobalConfigManager.shared.systemoInfoConfig?.expenseVehicleType ?? [:]),
            "is_edit": isEdit ? "1" : "0",
            "expense_id": eid,
            "subsidy_day": list[5].tfText == "0" ? "" : list[5].tfText,
            "subsidy_fee": list[6].tfText == "0" ? "" : list[6].tfText,
            "travel_id": travel!.id,
            "invoice_id": travel!.invoiceId
        ]
        
        BXApi.setTravelInfo(isPre: isPre, params: params) { [weak self] _ in
            self?.createTravleBlock?()
            self?.popViewController()
        }
    }
    
}

extension CreteTravelVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommonInputCell = tableView.dequeueReusableCell(withIdentifier: "CommonInputCell", for: indexPath) as! CommonInputCell
        cell.selectionStyle = .none
        cell.bindInputModel(list[indexPath.row])
        cell.textEndEditBlock = { [weak self]text in
            self?.list[indexPath.row].tfText = text
            if indexPath.row == 5 ||  indexPath.row == 6 {
                self?.isEdit = true
            }
        }
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 0 || indexPath.row == 1 {
            let result: DatePicker.DatePickerClosure = { [weak self] dateStr in
                self?.list[indexPath.row].tfText = dateStr
                tableView.reloadData()
            }
            let picker = DatePicker(.dateAndTime, handle: result)
            presentFromBottom(picker)
        }else if indexPath.row == 4 {
            guard let config = GlobalConfigManager.shared.systemoInfoConfig else { return}
            let values: [String] = config.expenseVehicleType_values
            
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
                    self?.list[indexPath.row].tfText = text
                }
                self?.tableVIew.reloadData()
            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36))
        let lab = UILabel(text: "行程信息", font: SCFont(14), nColor: UIColor(hexString: "#939AA3"))
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
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
        return 0.01
    }
    
}
