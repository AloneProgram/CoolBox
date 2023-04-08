//
//  BXCompleteInfoVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/9.
//

import UIKit

class BXCompleteInfoVC: EViewController {

    private var tableView = UITableView(frame: .zero, style: .grouped)
        
    var eid = ""
    var bxInfo: BXInfoModel?
    
    var list: [[Any]] = [ ]
    
    init(eId: String = "" ) {
        self.eid = eId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftTitle = "完整信息"
        
        list = travelBXInfoList()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.backgroundColor = .clear
       
        tableView.dataSource = self
        tableView.delegate = self
        let infoNib = UINib(nibName: "CommonInfoCell", bundle: nil)
        tableView.register(infoNib, forCellReuseIdentifier: "CommonInfoCell")
        let fpNib = UINib(nibName: "BXFapiaoCell", bundle: nil)
        tableView.register(fpNib, forCellReuseIdentifier: "BXFapiaoCell")
        let trNib = UINib(nibName: "TravelOtherFeeCell", bundle: nil)
        tableView.register(trNib, forCellReuseIdentifier: "TravelOtherFeeCell")
        
        tableView.estimatedRowHeight = 56
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        getExpeneInfo(eId: eid)
    }
    
    func travelBXInfoList() -> [[Any]] {
        return [
            [
                CommonInfoModel(leftText: "部门", rightText: bxInfo?.department ?? ""),
                CommonInfoModel(leftText: "日期", rightText: bxInfo?.date ?? ""),
                CommonInfoModel(leftText: "报销人", rightText: bxInfo?.username ?? ""),
                CommonInfoModel(leftText: "报销事由", rightText: bxInfo?.reason ?? ""),
            ],
            [
                CommonInfoModel(leftText: "报销总额", rightText: "¥" + (bxInfo?.totalFee ?? "")),
                CommonInfoModel(leftText: "预借旅费", rightText: "¥" + (bxInfo?.preGetFee ?? "")),
                CommonInfoModel(leftText: "补领金额", rightText: "¥" + (bxInfo?.regetFee ?? "")),
                CommonInfoModel(leftText: "退还金额", rightText: "¥" + (bxInfo?.returnFee ?? "")),
            ],
        ]
    }
    
    
    func getExpeneInfo(eId: String){
        BXApi.getExpenseInfo(eid: eId) { [weak self] info in
            self?.bxInfo = info
            self?.list = self?.travelBXInfoList() ?? []
            self?.list.append(info.travelData)
            self?.list.append(info.invoiceData)
  
            self?.tableView.reloadData()
        }
    }

}

extension BXCompleteInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0, 1:
            let cell: CommonInfoCell = tableView.dequeueReusableCell(withIdentifier: "CommonInfoCell", for: indexPath) as! CommonInfoCell
            cell.selectionStyle = .none
            cell.bindData(list[0][indexPath.row] as! CommonInfoModel)
            return cell
        case 2:
            let cell: BXFapiaoCell = tableView.dequeueReusableCell(withIdentifier: "BXFapiaoCell", for: indexPath) as! BXFapiaoCell
            cell.selectionStyle = .none
            cell.bindTravel(list[2][indexPath.row] as! TravleData)
            return cell
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
                self?.push(FPEditInfoVC(fpId, hiddenBottom: true))
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
   
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var text = ""
        switch section {
        case 0:    text = "报销信息"
        case 1:    text = ""
        case 2:    text = "差旅行程"
        case 3:    text = "其他费用"
        default:break
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: section == 1 ? 10 : 36))
        let lab = UILabel(text: text, font: SCFont(14), nColor: UIColor(hexString: "#939AA3"))
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 10 : 36
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        return 0.01
    }
  
}
