//
//  FPSelectListVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/29.
//

import UIKit

class FPSelectListVC: EViewController, RefreshFor, CYLTableViewPlaceHolderDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var selectBtn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    var list: [FaPiaoModel] = []
    
    var refreshBlock: ((Bool) -> Void)?
    
    var pageIndex = 1
    
    var selectId = ""
    
    init(_ selectId: String) {
        self.selectId = selectId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomViewHeight.constant = 48 + kBottomSpace
        
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
        
        addHeaderRefresh(scrollView: tableView)
        
        loadFapiao(nil)
        
        let btmView = BottomActionView(type: .fp_normal, frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 48))
        btmView.actionBlock = { [weak self] tag in
            switch tag {
            case 0:
                self?.deleteFP()
            case 1:
                self?.unbaleBX()
            case 2:
                self?.createBX()
            default:
                break
            }
        }
        
        bottomView.addSubview(btmView)
    }

    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        list.enumerated().forEach({ idx, model in
            var m = model
            m.isSelected = sender.isSelected
            list[idx] = m
        })
        updateFPStatus()
    }
    
    
     func makePlaceHolderView() -> UIView! {
        return UIView.blankMsgView("暂无发票", imageStr: "ic_noData")
    }
    
    func loadData(_ block: RefreshResult?) {
        loadFapiao(block)
    }

    
    func loadFapiao(_ block: RefreshResult?) {
        FPApi.requestFapiaoList(page: 1, pageSize: 100, status: 0) {[weak self] list in
            block?(true)
            self?.list = list.list
            self?.list.enumerated().forEach({ idx, model in
                var m = model
                m.isSelectListPage = true
                if m.id == self?.selectId {
                    m.isSelected = true
                }
                self?.list[idx] = m
            })
            self?.updateFPStatus()
            self?.tableView.cyl_reloadData()
        }
    }
    
    func updateFPStatus() {
        var isAllSelect = true
        
        var selectCount = 0
        list.filter({$0.isDataComplete == "1"}).forEach { fp in
            if !fp.isSelected {
                isAllSelect = false
            }
            if fp.isSelected {
                selectCount += 1
            }
        }
        
        selectBtn.isSelected = isAllSelect
        titleLabel.text = "已选\(selectCount)张发票"
        
        tableView.reloadData()
    }
    
    func deleteFP() {
        var selectCount = 0
        list.filter({$0.isDataComplete == "1"}).forEach { fp in
            if fp.isSelected {
                selectCount += 1
            }
        }
        let alert = SelectAlert(alertTitle: "确定删除这\(selectCount)张发票吗")
        let cancel = SelectAlertAction(title: "取消", type: .cancel)

        let deleteFP = SelectAlertAction(title: "删除", titleColor: UIColor(hexString: "#F53F3F")) { [weak self] in
            self?.deleteFPRequest()
        }
        
        alert.addAction(deleteFP)
        alert.addAction(cancel)
        alert.show()
    }
    
    func unbaleBX() {
        
    }
    
    func createBX() {
        
        
    }
    
    func deleteFPRequest() {
        var ids = ""
        list.filter({$0.isDataComplete == "1"}).forEach { fp in
            if fp.isSelected {
                ids += "\(fp.id),"
            }
        }
        if ids.hasSuffix(",") {
            ids = ids.subString(start: 0, length: ids.length - 1)
        }
        
        FPApi.deleteFP(idsStr: ids) {[weak self] _ in
            self?.loadFapiao(nil)
        }
    }
    
}

extension FPSelectListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FapiaoCell = tableView.dequeueReusableCell(withIdentifier: "FapiaoCell", for: indexPath) as! FapiaoCell
        cell.selectionStyle = .none
        cell.clickSelectedBlock = { [weak self] in
            if let strongSelf = self {
                strongSelf.list[indexPath.row].isSelected = !strongSelf.list[indexPath.row].isSelected
            }
            self?.updateFPStatus()
        }
        cell.bindFapiao(list[indexPath.row])
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        list[indexPath.row].isSelected = !list[indexPath.row].isSelected
        updateFPStatus()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.01
    }
}

