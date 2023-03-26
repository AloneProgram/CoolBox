//
//  BXListVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit

class BXListVC: ETableViewController {
    //0 "未审批"  1 "审批中",  2 "已通过",  3 "已拒绝"
    var tag = 0
    
    var list: [BaoxiaoModel] = []
    
    var refreshBlock: ((Bool) -> Void)?
    
    var filterModels: [[FIlterModel]] = [ ]
    
    var headView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 10))
    
    init(_ tag: Int) {
        super.init(nibName: nil, bundle: nil)
        self.tag = tag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.backgroundColor = .clear
        headView.backgroundColor = .white
        tableView.tableHeaderView = headView
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "BaoxiaoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BaoxiaoCell")
        tableView.estimatedRowHeight = 54
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addRefresh(scrollView: tableView)
        
        if tag == 0 {
             loadBXD(page: 1, block: refreshBlock)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAction(_:)), name: Notification.Name("ReloadBaoxiaoListData"), object: nil)
    }
    
    override func makePlaceHolderView() -> UIView! {
        return UIView.blankMsgView("暂无报销单", imageStr: "ic_noData")
    }
    
    override func loadData(_ block: ETableViewController.RefreshResult?) {
        pageIndex = 1
        refreshBlock = block
        
         loadBXD(page: pageIndex, block: block)
    }
    
    override func loadMoreDatas(_ block: ETableViewController.RefreshResult?) {
        refreshBlock = block
         loadBXD(page: pageIndex, block: block)
    }
    
    func loadBXD(page: Int, block: ETableViewController.RefreshResult?) {
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
        case 0, 1: status = tag
        case 2: status = 3
        case 3: status = 5
        default: break
        }
        
        BXApi.requestBaoxiaoList(page: page, startDate: startDate, endDate: endData, status: status, sort: sort) {[weak self] list in
            block?(list.list.count == 0)
            
            self?.tableView.tableHeaderView = list.list.count == 0 ? UIView() : self?.headView
            
            if page == 1 {
                self?.list = list.list
            }else {
                self?.list.append(contentsOf: list.list)
            }
            
            if list.list.count > 0 {
                self?.pageIndex += 1
            }
            
            self?.tableView.cyl_reloadData()
        }
    }
    
    @objc func reloadAction(_ noci: Notification){
        filterModels = noci.object as? [[FIlterModel]] ?? []
        tableView.mj_header?.beginRefreshing()
    }
    
}

extension BXListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BaoxiaoCell = tableView.dequeueReusableCell(withIdentifier: "BaoxiaoCell", for: indexPath) as! BaoxiaoCell
        cell.selectionStyle = .none
        cell.bindBaoxiao(list[indexPath.row])
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

