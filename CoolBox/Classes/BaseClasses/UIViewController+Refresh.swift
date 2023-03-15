//
//  UIViewController+Refresh.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh

fileprivate struct RefreshKey {
    static let refreshHeaderKey = UnsafeRawPointer(bitPattern: "refreshHeaderKey".hashValue)
    static let refreshFooterKey = UnsafeRawPointer(bitPattern: "refreshFooterKey".hashValue)
}

public extension UIViewController {
    var refreshHeader: MJRefreshNormalHeader? {
        set{
            guard let key = RefreshKey.refreshHeaderKey else { return }
            if let refresh = newValue {
                // 设置自动切换透明度(在导航栏下面自动隐藏)
                refresh.isAutomaticallyChangeAlpha = true
                // 隐藏时间
                refresh.lastUpdatedTimeLabel?.isHidden = true
                
                // 设置提示文字
                refresh.setTitle("下拉刷新", for: .idle)
                refresh.setTitle("释放更新", for: .pulling)
                refresh.setTitle("加载中...", for: .refreshing)
                
                refresh.labelLeftInset = 15
                refresh.arrowView?.image = UIImage(named: "refresh_arrow")
                
                objc_setAssociatedObject(self, key, refresh, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get{
            guard let key = RefreshKey.refreshHeaderKey else { return nil }
            return objc_getAssociatedObject(self, key) as? MJRefreshNormalHeader
        }
    }
    
    var refreshFooter: MJRefreshBackNormalFooter? {
        set{
            guard let key = RefreshKey.refreshFooterKey else { return }
            if let refresh = newValue {
                // 设置提示文字
                refresh.setTitle("上拉加载", for: .idle)
                refresh.setTitle("释放更多", for: .pulling)
                refresh.setTitle("加载中...", for: .refreshing)
                refresh.setTitle("已经拉到底了", for: .noMoreData)
                
                refresh.labelLeftInset = 15
                refresh.arrowView?.image = UIImage(named: "refresh_arrow")

                objc_setAssociatedObject(self, key, refresh, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get{
            guard let key = RefreshKey.refreshFooterKey else { return nil }
            return objc_getAssociatedObject(self, key) as? MJRefreshBackNormalFooter
        }
    }
    
    // MARK: - target->action

    func MJFreshCustomHeader(target: Any, action: Selector) -> MJRefreshNormalHeader {
        return MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: action)
    }
    
    func MJFreshCustomFooter(target: Any, action: Selector) -> MJRefreshBackNormalFooter {
        return MJRefreshBackNormalFooter(refreshingTarget: target, refreshingAction: action)
    }
    
    // MARK: - block
    
    func MJFreshCustomHeader(_ block: @escaping MJRefreshComponentAction) -> MJRefreshNormalHeader {
        return MJRefreshNormalHeader(refreshingBlock: block)
    }
    
    func MJFreshCustomFooter(_ block: @escaping MJRefreshComponentAction) -> MJRefreshBackNormalFooter {
        return MJRefreshBackNormalFooter(refreshingBlock: block)
    }
}
