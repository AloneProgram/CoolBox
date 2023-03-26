//
//  FilterVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/25.
//

import UIKit

struct FIlterModel {
    var title = ""
    var isSelected = false
    
    init(title: String, isSelected: Bool = false) {
        self.title = title
        self.isSelected = isSelected
    }
}

class FilterVC: UIViewController, PresentFromBottom {
        
    private var list: [[FIlterModel]] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    var tag = 0
    var filterModels: [[FIlterModel]] = []
    
    var titlies: [String] = []
    
    var filterBlock: (([[FIlterModel]]) -> Void)?
    
    init(_ tag: Int, params: [[FIlterModel]]) {
        self.tag = tag
        self.filterModels = params
        super.init(nibName: nil, bundle: nil)
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomHeight.constant = 76 + kBottomSpace
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "FilterCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FilterCell")
        tableView.estimatedRowHeight = 54
        tableView.separatorStyle = .none
       
        setDetaultData()
        if filterModels.count > 0 {
            list[0] = filterModels[0]
        }
       
        if filterModels.count > 1 {
            list[1] = filterModels[1]
        }
        
        if tag == 0 {
            getInvoiceTitleList()
        }
        
        tableView.reloadData()
        
       
    }
    
    
    @IBAction func resetAction(_ sender: Any) {
        setDetaultData()
        
        if titlies.count > 0 {
            var titleFilters: [FIlterModel] = []
            titlies.forEach { title in
                let f = FIlterModel(title: title)
                titleFilters.append(f)
            }
            
            list.append(titleFilters)
        }
        tableView.reloadData()
    }
    
    func setDetaultData() {
        switch tag {
        case 0:
            list = [
                [
                    FIlterModel(title: "消费时间近到远", isSelected: true),
                    FIlterModel(title: "消费时间远到近"),
                    FIlterModel(title: "发票金额大到小"),
                    FIlterModel(title: "发票金额小到大"),
                ],
                [
                    FIlterModel(title: ""),
                    FIlterModel(title: ""),
                ]
            ]
        case 1:
            list = [
                [
                    FIlterModel(title: "报销日期近到远", isSelected: true),
                    FIlterModel(title: "报销日期远到近"),
                    FIlterModel(title: "报销金额大到小"),
                    FIlterModel(title: "报销金额小到大"),
                ],
                [
                    FIlterModel(title: ""),
                    FIlterModel(title: ""),
                ]
            ]
        case 2:
            list = [
                [
                    FIlterModel(title: "报销日期近到远", isSelected: true),
                    FIlterModel(title: "报销日期远到近"),
                    FIlterModel(title: "报销金额大到小"),
                    FIlterModel(title: "报销金额小到大"),
                ],
                [
                    FIlterModel(title: ""),
                    FIlterModel(title: ""),
                ]
            ]
        default:
            break
        }
    }
    
    
    @IBAction func sureAction(_ sender: Any) {
        var tmp: [[FIlterModel]] = []
        var noFilter = list[0][0].isSelected && list[1][0].title.length == 0 && list[1][1].title.length == 0
        if list.count == 3 {
            noFilter = noFilter && list[2].filter({$0.isSelected}).count == 0
        }
        
        if !noFilter {
            tmp = list
        }
        
        filterBlock?(tmp)
        dismiss(animated: true)
    }
    
    func getInvoiceTitleList() {
        MineApi.getInvoiceTitleList { [weak self] list in
            self?.titlies = list
            if self?.filterModels.count ?? 0 > 2 {
                self?.list.append(self?.filterModels[2] ?? [])
            }else {
                var titleFilters: [FIlterModel] = []
                list.forEach { title in
                    let f = FIlterModel(title: title)
                    titleFilters.append(f)
                }
                self?.list.append(titleFilters)
            }
            self?.tableView.reloadData()
        }
    }
    
    func selectDate(_ row: Int) {
        let handle: DatePicker.DatePickerClosure = { [weak self] str in
            self?.list[1][row].title = str
            self?.tableView.reloadData()
        }
        presentFromBottom(DatePicker(handle: handle))
    }

}

extension FilterVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FilterCell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.selectionStyle = .none
        cell.bindFilter(list[indexPath.section][indexPath.row], indexPath: indexPath)
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0 :
            list[0].enumerated().forEach { i,f in
                var tmp = f
                tmp.isSelected = false
                list[0][i] = tmp
            }
            list[0][indexPath.row].isSelected = true
        case 1:
            selectDate(indexPath.row)
        case 2:
            list[2].enumerated().forEach { i,f in
                var tmp = f
                tmp.isSelected = false
                list[2][i] = tmp
            }
            list[2][indexPath.row].isSelected = true
        default:
            break
        }
     
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var str = ""
        switch section {
        case 0 : str = "排序规则"
        case 1:
            str = tag == 0 ? "消费时间" : "报销日期"
        case 2:
            str = "发票抬头"
        default:
            break
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 38))
        let lab = UILabel(text: str, font: Font(14), nColor: UIColor(hexString: "#939AA3"))
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.left.equalTo(17)
            make.centerY.equalToSuperview()
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.01
    }
}
