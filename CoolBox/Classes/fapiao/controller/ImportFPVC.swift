//
//  ImportFPVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/28.
//

import UIKit

class ImportFPVC: EViewController {
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    var list: [[FaPiaoModel]] = []
    
    init(_ list: CameraImportFaPiaoList) {
        self.list = [list.list, list.invalidList]
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftTitle = "确定导入"

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.backgroundColor = .clear
       
    
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "FapiaoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FapiaoCell")
        tableView.estimatedRowHeight = 54
        tableView.separatorStyle = .none
        
        tableView.reloadData()
    }

    @IBAction func retakeAction(_ sender: Any) {
        popViewController()
        
        let vc = CamareImportVC(isScaneImport: false)
        vc.modalPresentationStyle = .fullScreen
        AppCommon.getCurrentVC()?.present(vc, animated: true)
        
    }
    
    @IBAction func importAction(_ sender: Any) {
        guard  list[0].count > 0  else {
            EToast.showInfo("无可导入的发票")
            return
        }
        var ids = ""
        list[0].forEach { model in
            ids += "\(model.invoiceId),"
        }
        
        if ids.hasSuffix(",") {
            ids = ids.subString(start: 0, length: ids.length - 1)
        }
        
        FPApi.invoiceImport(idsStr: ids) {[weak self] success in
            if success {
                NotificationCenter.default.post(name: Notification.Name("ImportFPSuccess"), object: nil)
                self?.popViewController()
            }
        }
    }
}

extension ImportFPVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FapiaoCell = tableView.dequeueReusableCell(withIdentifier: "FapiaoCell", for: indexPath) as! FapiaoCell
        cell.selectionStyle = .none
        cell.clickSelectedBlock = {
            
        }
        cell.bindFapiao(list[indexPath.section][indexPath.row])
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fapiao = list[indexPath.row]

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var str = ""
        
        if section == 0 {
            str = "可导入的发票（\(list[section].count)）"
        }else {
            str = "无法可导入的发票（\(list[section].count)）"
        }
        
        let labe = UILabel(text: str, font: MediumFont(18), nColor: UIColor(hexString: "#1D2129"))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 34))
        view.backgroundColor = .white
        view.addSubview(labe)
        labe.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(8)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  20
    }
}
