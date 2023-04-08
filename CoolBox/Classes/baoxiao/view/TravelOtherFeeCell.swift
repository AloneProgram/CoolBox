//
//  TravelOtherFeeCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/8.
//

import UIKit

class TravelOtherFeeCell: UITableViewCell {
    
    @IBOutlet weak var kindLabel: UILabel!
    
    @IBOutlet weak var feeLabel: UILabel!
    
    @IBOutlet weak var arrowIcon: UIImageView!
    
    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var topView: UIView!
    
    var list: [FapiaoDetailModel] = []
    
    var tapBlock:(() -> Void)?
    
    var clickFPBlock:((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        if #available(iOS 15.0, *) {
            tableVIew.sectionHeaderTopPadding = 0
        }
        tableVIew.backgroundColor = .clear
        
        tableVIew.dataSource = self
        tableVIew.delegate = self
        let fpNib = UINib(nibName: "BXFapiaoCell", bundle: nil)
        tableVIew.register(fpNib, forCellReuseIdentifier: "BXFapiaoCell")
        tableVIew.tableFooterView = UIView()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        topView.addGestureRecognizer(gesture)
    }
    
    func bindInvoice(_ invoiceList: InvoiceData) {
        self.list = invoiceList.list
        tableVIew.reloadData()
        tableViewHeight.constant = CGFloat(invoiceList.isExapnded ? 74 * list.count : 0)
        arrowIcon.image = invoiceList.isExapnded ? UIImage(named: "arrow_up") : UIImage(named: "arrow_down")
        
        let kind = GlobalConfigManager.getValue(with: invoiceList.catId, in: GlobalConfigManager.shared.systemoInfoConfig?.expenseCatId ?? [:])
        kindLabel.text = "\(kind)(\(invoiceList.count))"
        feeLabel.text = "¥\(invoiceList.fee)"
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func tapAction() {
        tapBlock?()
    }    
}

extension TravelOtherFeeCell: UITableViewDelegate, UITableViewDataSource {
    
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell: BXFapiaoCell = tableView.dequeueReusableCell(withIdentifier: "BXFapiaoCell", for: indexPath) as! BXFapiaoCell
        cell.selectionStyle = .none
        cell.bindInvoiceData(list[indexPath.row], autoSize: false)
        return cell
      
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fp = list[indexPath.row]
        clickFPBlock?(fp.id)
   
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.01
    }
    
}
