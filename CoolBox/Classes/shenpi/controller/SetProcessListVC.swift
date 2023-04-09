//
//  SetProcessListVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/9.
//

import UIKit

class SetProcessListVC: EViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    private var imageView = UIImageView(image: UIImage(named: "scrllo_delete"))
    
    var firstNodel: Process {
        return Process(nodeName: "发起审批")
    }
    var lastNodel: Process {
        return Process(nodeName: "完成审批")
    }
    
    private var list: [Process] = []
    
    var cid = ""
    
    var commitBlock:(() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftTitle = "设置审批流程"
        bottomViewHeight.constant = 48 + kBottomSpace
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.backgroundColor = .clear
       
        tableView.dataSource = self
        tableView.delegate = self

        let nib = UINib(nibName: "ProcessNodelCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ProcessNodelCell")
        tableView.separatorStyle = .none
        
        let hasShow = UserDefaults.standard.bool(forKey: "HasShowScrlloBg")
        
        if !hasShow {
            let tap = UITapGestureRecognizer(target: self, action: #selector(removeMask))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tap)
            view.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        getInfo()
    }
    
    func getInfo() {
        
        SPApi.getProcessInfo(cid: Login.currentAccount().companyId) {[weak self] nodel in
            self?.cid = nodel.cId
            self?.list = nodel.examineProcess
            if let nodel = self?.firstNodel {
                self?.list.insert(nodel, at: 0)
            }
            if let nodel = self?.lastNodel {
                self?.list.append(nodel)
            }
            self?.tableView.reloadData()
        }
    }
    
    @objc func removeMask() {
        imageView.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: "HasShowScrlloBg")
    }


    @IBAction func saveAction(_ sender: Any) {
        
        var processDicArr: [[String: Any]] = []
        list.forEach { model in
            var params: [String: String] = [:]
            if model.nodeName != "发起审批", model.nodeName != "完成审批" {
                params["node_name"] = model.nodeName
                processDicArr.append(params)
            }
        }
        guard var dataStr = JSON(processDicArr).rawString() else { return}
        dataStr = dataStr.replacingOccurrences(of: "\n", with: "")
        dataStr = dataStr.replacingOccurrences(of: " ", with: "")
        
        let params: [String: String] = [
            "c_id": cid,
            "examine_process": dataStr
        ]
        SPApi.setProcessInfo(params: params) { [weak self]_ in
            EToast.showSuccess("保存成功")
            self?.commitBlock?()
            self?.popViewController()
        }
    }
}

extension SetProcessListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProcessNodelCell = tableView.dequeueReusableCell(withIdentifier: "ProcessNodelCell", for: indexPath) as! ProcessNodelCell
        cell.selectionStyle = .none
        cell.bindNode(node: list[indexPath.row], isLast: indexPath.row == list.count - 1)
        cell.saveNodeBlock = {[weak self]  nodeName in
            self?.list[indexPath.row].isAdd = false
            let node = Process(nodeName: nodeName)
            self?.list.insert(node, at: indexPath.row + 1)
            self?.tableView.reloadData()
        }
        cell.addNodeBlock = {[weak self] isAdd in
            self?.list[indexPath.row].isAdd = isAdd
            self?.tableView.reloadData()
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return list[indexPath.row].isAdd ? 108 : 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36))
        let lab = UILabel(text: "审批流程", font: SCFont(14), nColor: UIColor(hexString: "#939AA3"))
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] (action, view, completion) in
            self?.list.remove(at: indexPath.row)
            tableView.reloadData()
            completion(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0 &&  indexPath.row != list.count - 1
    }
    
}
