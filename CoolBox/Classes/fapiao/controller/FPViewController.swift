//
//  FPViewController.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/15.
//

import UIKit
import Parchment

struct PageTab {
    var title = ""
    var isSelected = false

    init(_ title: String, isSelected: Bool) {
        self.title = title
        self.isSelected = isSelected
    }
}



class FPViewController: EViewController {
    
    private var headerView = ImportEntranceView.instance()
    
    var filtetEntraceView = FilterEntraceView.instance()

    override var navigationBarStyle: NavigationBarStyle { return .transparentBackground }
    
    var list: [String] = [ "未报销","报销中","已报销", "无需报销"]
    
    var listVC: [FPListVC] = [ ]
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EColor.viewBgColor
        self.bigLeftTitle = "导入发票"
        
        listVC = [
            FPListVC(0),
            FPListVC(1),
            FPListVC(2),
            FPListVC(3),
        ]
        
        headerView.importActionBlock = { [weak self] tag in
            self?.importAction(tag)
        }
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kNaviBarHeight)
            make.height.equalTo(140)
        }
        
        view.addSubview(pagingViewController.view)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
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
    
    func importAction(_ tag: Int) {
        switch tag {
        case 0: scanImport()
        case 1: wxImport()
        case 2: aliImprot()
        case 3: tabkeImport()
        case 4: emailImport()
        default:break
        }
    }
    
    func showFilter() {
        let vc = FilterVC(0, params: filterModels)
        vc.filterBlock = { [weak self] filter in
            self?.filterModels = filter
            self?.filtetEntraceView.filterBtn.isSelected = filter.count > 0
            NotificationCenter.default.post(name: Notification.Name("ReloadFapiaoListData"), object: filter)
        }
        gy_showSide({ (config) in
            config.direction = .right
            config.animationType = .translationMask
            config.sideRelative = 0.77
        }, vc)
    }
}


extension FPViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
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
            vc.loadFapiao(page: 1, block: vc.refreshBlock)
        }
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        if let pagingIndexItem = pagingItem as? PagingIndexItem {
            let vc = listVC[pagingIndexItem.index]
            vc.loadFapiao(page: 1, block: vc.refreshBlock)
        }
    }
}


extension FPViewController {
    
    func scanImport() {
        let vc = CamareImportVC(isScaneImport: true)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func wxImport(){
        
    }
    
    func aliImprot() {
        
    }
    
    func tabkeImport() {
        let vc = CamareImportVC(isScaneImport: false)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func emailImport() {
        
    }
}


class CusPagingIndicatorView: PagingIndicatorView {
    override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
      super.apply(layoutAttributes)
      if let attributes = layoutAttributes as? PagingIndicatorLayoutAttributes {
        backgroundColor = attributes.backgroundColor
        frame = CGRect(origin: frame.origin, size: CGSize(width: 24, height: frame.height))
        center = layoutAttributes.center
      }
    }
}
