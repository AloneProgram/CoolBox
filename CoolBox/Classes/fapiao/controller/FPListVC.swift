//
//  FPListVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/25.
//

import UIKit

class FPListVC: ETableViewController, PresentToCenter {
    //0 "未报销"  1 "报销中",  2 "已报销",  3 "无需报销"
    var tag = 0
    
    var list: [FaPiaoModel] = []
    
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
        let nib = UINib(nibName: "FapiaoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FapiaoCell")
        tableView.estimatedRowHeight = 54
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(-kTabbarHeight)
        }

        addRefresh(scrollView: tableView)
        
        if tag == 0 {
            loadFapiao(page: 1, block: refreshBlock)
            NotificationCenter.default.addObserver(self, selector: #selector(reloadAction(_:)), name: Notification.Name("ImportFPSuccess"), object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAction(_:)), name: Notification.Name("ReloadFapiaoListData"), object: nil)
    }
    
    override func makePlaceHolderView() -> UIView! {
        return UIView.blankMsgView("暂无发票", imageStr: "ic_noData")
    }
    
    override func loadData(_ block: ETableViewController.RefreshResult?) {
        pageIndex = 1
        refreshBlock = block
        
        loadFapiao(page: pageIndex, block: block)
    }
    
    override func loadMoreDatas(_ block: ETableViewController.RefreshResult?) {
        refreshBlock = block
        loadFapiao(page: pageIndex, block: block)
    }
    
    func loadFapiao(page: Int, block: ETableViewController.RefreshResult?) {
        var sort = 1
        var startDate = ""
        var endData = ""
        var title = ""
        if filterModels.count > 0 {
            filterModels[0].enumerated().forEach { idx, f in
                if f.isSelected {
                    sort = idx + 1
                }
            }
            
            startDate =  filterModels[1][0].title
            endData =  filterModels[1][1].title
          
            filterModels[2].forEach { f in
                if f.isSelected {
                    title = f.title
                }
            }
        }
        
        var status = 0
        switch tag {
        case 0, 1: status = tag
        case 2: status = 3
        case 3: status = 5
        default: break
        }
        
        FPApi.requestFapiaoList(page: page, title: title, startDate: startDate, endDate: endData, status: status, sort: sort) {[weak self] list in
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
    
    func deleteFapiao(_ fapiao: FaPiaoModel) {
        FPApi.deleteFP(idsStr: fapiao.id) {[weak self] success in
            if success, let strongSelf = self {
                strongSelf.loadData(strongSelf.refreshBlock)
            }
        }
    }
}

extension FPListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FapiaoCell = tableView.dequeueReusableCell(withIdentifier: "FapiaoCell", for: indexPath) as! FapiaoCell
        cell.selectionStyle = .none
        cell.clickSelectedBlock = {
            
        }
        cell.bindFapiao(list[indexPath.row])
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fapiao = list[indexPath.row]
        
        if fapiao.isSync == "2" {
            //点击删除
            let alert = CustomAlert(title: "系统提示", content: "请删除后重新导入", confirmTitle: "删除") { [weak self] in
                self?.deleteFapiao(fapiao)
            }
            presentToCenter(alert)
        }

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

