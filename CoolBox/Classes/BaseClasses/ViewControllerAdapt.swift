//
//  ViewControllerAdapt.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

// MARK: - ParamAdapt

/// A -> B 传递参数，B 遵守 `ParamAdapt`
protocol ParamAdapt {
    /// A -> B 传递参数，B 用来接收参数
    /// - Parameter param: 需要传递的参数
    func paramArriveAt(_ param: Any?)
    
    /// A -> B 之间传递参数
    ///
    /// 注意：此方法 只需 B 来调用，且是在 A 处完成调用；
    /// 在 B 处 `paramArriveAt` 用来接收
    /// - Parameter param: 需要传递的参数
    func paramFromAdapt(_ param: Any?)
}

extension ParamAdapt {
    var actionAgain: ParamAdaptAgain? { get { return nil} set{}}
    
    func paramFromAdapt(_ param: Any?) {
        print("paramAdapt param = \(String(describing: param))")
        paramArriveAt(param)
    }
}

// 二次动作的APP内链跳转协议
struct ParamAdaptAgain {
    enum ActionType: String {
        // 内链
        case router = "router"
        // 动作
        case `do` = "do"
        case none
    }
    
    var actionType: ParamAdaptAgain.ActionType = .none
    var actionParam: String?
}

protocol ParamAdaptAction: ParamAdapt {
    /// 是否存在 二次动作的APP内链跳转协议
    var actionAgain: ParamAdaptAgain? { get set }
    func actionAgainFrom(_ param: Any?) -> ParamAdaptAgain?
}

extension ParamAdaptAction {
    
    func actionAgainFrom(_ param: Any?) -> ParamAdaptAgain? {
        guard let param = param as? [String: Any] else { return nil }
        
        if let typeS = param["actionType"] as? String,
            let type = ParamAdaptAgain.ActionType(rawValue: typeS) {
            
            var actionParam: String?
            if let string = param["actionParam"] as? String {
                actionParam = string.removingPercentEncoding
            }
            return ParamAdaptAgain(actionType: type, actionParam: actionParam)
        }
        return nil
    }
}

// MARK: - RefreshFor
protocol RefreshFor {
    
    typealias RefreshResult = (_ noMoreData: Bool) -> Void
    
    /// loadData 具体的 数据请求
    ///
    /// - Parameter block: 是否还有更多的数据
    func loadData(_ block: RefreshResult?)
    
    /// loadMoreDatas 具体的 数据请求
    ///
    /// - Parameter block: 是否还有更多的数据
    func loadMoreDatas(_ block: RefreshResult?)
}

extension RefreshFor {
    func loadData(_ block: RefreshResult?) {}
    func loadMoreDatas(_ block: RefreshResult?) {}
}

extension RefreshFor where Self: UIViewController {
    
    /// 添加刷新refreshHeader
    ///
    /// - Parameter view: ScrollView子类
    func addHeaderRefresh(scrollView view: UIScrollView) {
        self.refreshHeader = MJFreshCustomHeader { [weak self] in
            guard let `self` = self else { return }
            self.refreshData()
        }
        view.mj_header = self.refreshHeader
    }
    
    /// 添加尾部 加载更多refreshFooter
    ///
    /// - Parameter view: ScrollView子类
    func addFooterRefresh(scrollView view: UIScrollView) {
        self.self.refreshFooter = MJFreshCustomFooter { [weak self] in
            guard let `self` = self else { return }
            self.refreshMoreData()
        }
        view.mj_footer = self.refreshFooter
    }
    
    /// 添加刷新refreshHeader，和加载更多refreshFooter
    ///
    /// - Parameter view: ScrollView子类
    func addRefresh(scrollView view: UIScrollView) {
        addHeaderRefresh(scrollView: view)
        addFooterRefresh(scrollView: view)
    }
    
    func beginRefreshing() {
        refreshHeader?.beginRefreshing()
    }
    
    private func loadSomeData(_ block: RefreshResult?) {
        self.loadData(block)
    }
    
    private func loadMoreData(_ block: RefreshResult?) {
        self.loadMoreDatas(block)
    }
    
    /// 强制调用 loadData(:)
    func refreshData() {
        loadSomeData { [weak self] (noMoreData) in
            guard let `self` = self else { return }

            self.refreshHeader?.endRefreshing()
            if noMoreData {
                self.refreshFooter?.endRefreshingWithNoMoreData()
            }
            else {
                self.refreshFooter?.resetNoMoreData()
            }
        }
    }
    
    private func refreshMoreData() {
        loadMoreData { [weak self] (noMoreData) in
            guard let `self` = self else { return }
            if noMoreData {
                self.refreshFooter?.endRefreshingWithNoMoreData()
            }
            else {
                self.refreshFooter?.endRefreshing()
            }
        }
    }
}

// MARK: - push & pushToWebView
extension UIViewController {
    
    func push(_ vc: UIViewController, params: Any? = nil) {
        if let nav = self as? UINavigationController {
            nav.pushViewController(vc, animated: true)
            if let params = params, let vc = vc as? ParamAdapt {
                vc.paramFromAdapt(params)
            }
            return
        }
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
            if let params = params, let vc = vc as? ParamAdapt {
                vc.paramFromAdapt(params)
            }
        }
        else {
            ELog(message: "navigationController = nil")
        }
    }
    
    func pushToWebView(_ urlString: String?) {
        guard let url = urlString else { return }
        let webVC = WebViewController(urlString: url)
        if let nav = self.navigationController {
            nav.pushViewController(webVC, animated: true)
        }
        else if let nav = self as? UINavigationController {
            nav.pushViewController(webVC, animated: true)
        }
        else {
            //TODO: 需要创建 nav
        }
    }
}
