//
//  BXViewController.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/15.
//

import UIKit
import Parchment

class BXViewController: EViewController {

    var filtetEntraceView = FilterEntraceView.instance()
    
    var list: [String] = [ "未审批","审批中","已通过", "已拒绝"]
    
    var listVC: [BXListVC] = [ ]
        
    lazy private var pagingViewController: PagingViewController = {
        let pagingVC = PagingViewController()
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
        pagingVC.menuItemSize = .fixed(width: (kScreenWidth - 79.0) / CGFloat(list.count), height: 44)
        pagingVC.menuItemSpacing = 0
        pagingVC.menuInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pagingVC.view.translatesAutoresizingMaskIntoConstraints = false
        pagingVC.view.backgroundColor = .white
        return pagingVC
    }()
    
    var filterModels: [[FIlterModel]] = [ ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.Name("BackToReloadBXListData"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EColor.viewBgColor
        self.bigLeftTitle = "报销单列表"
        
        listVC = [
            BXListVC(0),
            BXListVC(1),
            BXListVC(2),
            BXListVC(3)
        ]
   
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
}


extension BXViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return list.count
    }
    
    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return listVC[index]
    }
    
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return  PagingIndexItem(index: index, title: list[index])
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        if let pagingIndexItem = pagingItem as? PagingIndexItem {
            let vc = listVC[pagingIndexItem.index]
            vc.loadBXD(page: 1, block: vc.refreshBlock)
        }
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        if let pagingIndexItem = pagingItem as? PagingIndexItem {
            let vc = listVC[pagingIndexItem.index]
            vc.loadBXD(page: 1, block: vc.refreshBlock)
        }
    }
}
