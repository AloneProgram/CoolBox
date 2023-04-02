//
//  SPViewController.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/15.
//

import UIKit
import Parchment

class SPViewController: EViewController {
    
    var filtetEntraceView = FilterEntraceView.instance()
    
    var list: [SPPagingItem] = [
        SPPagingItem(showRed: false, index: 0, title: "待审批"),
        SPPagingItem(showRed: false, index: 1, title: "已审批"),
        SPPagingItem(showRed: false, index: 2, title: "已发起")
    ]
    
    var fistVC = SPListVC(0)
    var secVC = SPListVC(1)
    var thirdVC = SPListVC(2)
    
    var listVC: [SPListVC] = []
    
    lazy private var pagingViewController: PagingViewController = {
        let pagingVC = PagingViewController()
        pagingVC.register(SPPagingCell.self, for: SPPagingItem.self)
        pagingVC.collectionView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 79)
        pagingVC.dataSource = self
        pagingVC.delegate = self
        pagingVC.indicatorColor =  UIColor(hexString: "#165DFF")
        pagingVC.indicatorOptions = .visible(height: 2,
                                             zIndex: Int.max,
                                             spacing: UIEdgeInsets.zero,
                                             insets: UIEdgeInsets.zero)
        pagingVC.indicatorClass = CusPagingIndicatorView.self
        pagingVC.textColor = UIColor(hexString: "#1D2129")
        pagingVC.selectedTextColor = UIColor(hexString: "#165DFF")
        pagingVC.font = Font(16)
        pagingVC.selectedFont = MediumFont(16)
        pagingVC.borderColor = .clear
        pagingVC.borderOptions = .visible(height: 0, zIndex: 1, insets: UIEdgeInsets.zero)
        pagingVC.menuItemLabelSpacing = 0
        pagingVC.menuItemSize = .fixed(width: 74, height: 44)
        pagingVC.menuItemSpacing = (kScreenWidth - 74 * 3 - 79) / 3
        pagingVC.menuInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pagingVC.view.translatesAutoresizingMaskIntoConstraints = false
        pagingVC.view.backgroundColor = .white
        return pagingVC
    }()
    
    var filterModels: [[FIlterModel]] = [ ]
    
    private var spBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("设置审批流", for: .normal)
        button.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        button.titleLabel?.font = SCFont(16)
        button.addTarget(self, action: #selector(setSehnpiProcess), for: .touchUpInside)
        return button
    }()
    
    private var leftTitlteLabel: UILabel = {
        let title = UILabel(text: "审批列表", font: MediumFont(18), nColor: UIColor(hexString: "#1D2129"))

        return title
    }()
    
    private var spacer: UIView = {
        let spacer = UIView()
        let constraint = spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: CGFloat.greatestFiniteMagnitude)
        constraint.isActive = true
        constraint.priority = .defaultLow
        return spacer
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMySPList()
        getMySendSPList()
        
        if Login.currentAccount().isCompanyAdmin {
            let stack = UIStackView(arrangedSubviews: [leftTitlteLabel, spacer, spBtn])
            stack.axis = .horizontal
            navigationItem.titleView = stack
        }else {
            let stack = UIStackView(arrangedSubviews: [leftTitlteLabel, spacer])
            stack.axis = .horizontal
            navigationItem.titleView = stack
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EColor.viewBgColor
      
        listVC = [fistVC, secVC, thirdVC]
        
   
        view.addSubview(pagingViewController.view)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
       
        filtetEntraceView.clickBlock = { [weak self] in
            self?.showFilter()
        }
        
        view.addSubview(filtetEntraceView)
        filtetEntraceView.snp.makeConstraints { make in
            make.top.right.equalTo(pagingViewController.view)
            make.size.equalTo(CGSize(width: 79, height: 42))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPaggingItem), name: Notification.Name("ReloadSPPagingItem"), object: nil)
        
    }

    func showFilter() {
        let vc = FilterVC(1, params: filterModels)
        vc.filterBlock = { [weak self] filter in
            self?.filterModels = filter
            self?.filtetEntraceView.filterBtn.isSelected = filter.count > 0
            NotificationCenter.default.post(name: Notification.Name("ReloadBaoxiaoListData"), object: filter)
        }
        gy_showSide({ (config) in
            config.direction = .right
            config.animationType = .translationMask
            config.sideRelative = 0.77
        }, vc)
    }
    
    @objc func reloadPaggingItem() {
        getMySPList()
        getMySendSPList()
    }
    
    @objc func setSehnpiProcess() {
        
    }
    
    func getMySPList() {
        SPApi.requestMySPDList(page: 1, status: 0) {[weak self] list in
            self?.list[0].showRed = list.count > 0
            self?.pagingViewController.reloadMenu()
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "shoppingBagCountChanged"), object: list.count)
        }
    }
    
    func getMySendSPList() {
        SPApi.requestMySendSPDList(page: 1) {[weak self] list in
            self?.list[2].showRed = list.unreadCount > 0
            self?.pagingViewController.reloadMenu()
        }
    }
}


extension SPViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return list.count
    }
    
    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return listVC[index]
    }
    
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return list[index]
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        if let pagingIndexItem = pagingItem as? PagingIndexItem {
            let vc = listVC[pagingIndexItem.index]
            vc.loadSP(page: 1, block: vc.refreshBlock)
        }
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        if let pagingIndexItem = pagingItem as? PagingIndexItem {
            let vc = listVC[pagingIndexItem.index]
            vc.loadSP(page: 1, block: vc.refreshBlock)
        }
    }
}
