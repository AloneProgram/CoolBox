//
//  NavTransition.swift
//  huandian
//
//  Created by jhin on 2021/2/2.
//  Copyright © 2021 immptor. All rights reserved.
//

import UIKit

/**
 *  动画过渡代理管理的是push还是pop
 */
enum NaviOneTransitionType: Int {
    case push = 0
    case pop
}

class NavTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private var type: NaviOneTransitionType?
    private var fromVC: UIViewController?
    private var toVC: UIViewController?
    
    init(_ type: NaviOneTransitionType, fromVC: UIViewController, toVC: UIViewController) {
        self.type = type
        self.fromVC = fromVC
        self.toVC = toVC
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch type {
        case .push:
            doPushAnimation(transitionContext: transitionContext)
        case .pop:
            doPopAnimation(transitionContext: transitionContext)
        case .none:
            break
        }
    }

    /**
     *  执行push过渡动画
     */
    private func doPushAnimation(transitionContext: UIViewControllerContextTransitioning) {
        //目前该转场动画只添加从逛逛点击跳转详情页
        guard let fromVC = fromVC as? BrowseContentVC, let toVC = toVC as? ContentDetailVC else { return }
        
    }
    
    private func doPopAnimation(transitionContext: UIViewControllerContextTransitioning) {
        
    }
    
}
