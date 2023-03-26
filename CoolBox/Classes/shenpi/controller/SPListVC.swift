//
//  SPListVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

class SPListVC: ETableViewController, PresentFromBottom {

    //0 "待审批"  1 "已审批",  2 "已发起"
    var tag = 0
    
    var list: [SPModel] = []
    
    var refreshBlock: ((Bool) -> Void)?
    
    var filterModels: [[FIlterModel]] = [ ]
        
    init(_ tag: Int) {
        super.init(nibName: nil, bundle: nil)
        self.tag = tag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        let uncheckNib = UINib(nibName: "SPUnchckedCell", bundle: nil)
        tableView.register(uncheckNib, forCellReuseIdentifier: "SPUnchckedCell")
        let nib = UINib(nibName: "SPInfoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SPInfoCell")
        tableView.estimatedRowHeight = 54
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addRefresh(scrollView: tableView)
        
        loadSP(page: 1, block: refreshBlock)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAction(_:)), name: Notification.Name("ReloadBaoxiaoListData"), object: nil)
    }
    
    override func makePlaceHolderView() -> UIView! {
        return UIView.blankMsgView("暂无相关审批", imageStr: "ic_noData")
    }
    
    override func loadData(_ block: ETableViewController.RefreshResult?) {
        pageIndex = 1
        refreshBlock = block
        
         loadSP(page: pageIndex, block: block)
    }
    
    override func loadMoreDatas(_ block: ETableViewController.RefreshResult?) {
        refreshBlock = block
         loadSP(page: pageIndex, block: block)
    }
    
    func loadSP(page: Int, block: ETableViewController.RefreshResult?) {
        var sort = 1
        var startDate = ""
        var endData = ""
        if filterModels.count > 0 {
            filterModels[0].enumerated().forEach { idx, f in
                if f.isSelected {
                    sort = idx + 1
                }
            }
            startDate =  filterModels[1][0].title
            endData =  filterModels[1][1].title
        }
        
        var status = 0
        switch tag {
        case 0: status = 0
        case 1: status = 3
        default: break
        }
        
        if tag == 2 {
            SPApi.requestMySendSPDList(page: page, startDate: startDate, endDate: endData, sort: sort) { [weak self] list in
                block?(list.list.count == 0)
                                
                if page == 1 {
                    self?.list = list.list
                }else {
                    self?.list.append(contentsOf: list.list)
                }
                
                if list.list.count > 0 {
                    self?.pageIndex += 1
                }
                
                self?.tableView.cyl_reloadData()
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadSPPagingItem"), object: nil)
            }
        }else {
            SPApi.requestMySPDList(page: page, startDate: startDate, endDate: endData, status: status, sort: sort) { [weak self] list in
                block?(list.list.count == 0)
                                
                if page == 1 {
                    self?.list = list.list
                }else {
                    self?.list.append(contentsOf: list.list)
                }
                
                if list.list.count > 0 {
                    self?.pageIndex += 1
                }
                
                self?.tableView.cyl_reloadData()
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadSPPagingItem"), object: nil)
            }
        }
    }
    
    @objc func reloadAction(_ noci: Notification){
        filterModels = noci.object as? [[FIlterModel]] ?? []
        tableView.mj_header?.beginRefreshing()
    }
    
    func inputRefuseRason(row: Int) {
        let handler: ((String) -> Void) = {[weak self] text in
            self?.handleSPD(row: row, refuse: true, reson: text)
        }
        let alert = SP_RefuseReasonAlert(handle: handler)
        presentFromBottom(alert)
    }
    
    
    func handleSPD(row: Int, refuse: Bool, reson: String = "") {
        let sp = list[row]
        SPApi.handleSPD(id: sp.examineId, status: refuse ? 5 : 3, reson: reson) {[weak self] success in
            if success {
                self?.loadSP(page: 1, block: self?.refreshBlock)
            }
        }
    }
}

extension SPListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tag == 0 {
            let cell: SPUnchckedCell = tableView.dequeueReusableCell(withIdentifier: "SPUnchckedCell", for: indexPath) as! SPUnchckedCell
            cell.selectionStyle = .none
            cell.resuseBlock = { [weak self] in
                self?.inputRefuseRason(row: indexPath.row)
            }
            cell.agreeBlock = {[weak self] in
                self?.handleSPD(row: indexPath.row, refuse: false)
            }
            cell.bindSP(list[indexPath.row])
            return cell
        }
        let cell: SPInfoCell = tableView.dequeueReusableCell(withIdentifier: "SPInfoCell", for: indexPath) as! SPInfoCell
        cell.bindSP(list[indexPath.row], tag: tag)
        cell.selectionStyle = .none
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tag == 0 {
            return 200
        }
        return 182
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let bdx = list[indexPath.row]

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

