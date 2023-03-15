//
//  InteractiveTransition.swift
//  huandian
//
//  Created by jhin on 2021/2/2.
//  Copyright © 2021 immptor. All rights reserved.
//

import UIKit

///手势的方向
enum InteractiveTransitionGestureDirection: Int {
    case left = 0
    case right = 1
    case up = 2
    case down = 3
}

///手势控制哪种转场
enum InteractiveTransitionType: Int {
    case present = 0
    case dismiss = 1
    case push = 2
    case pop = 3
}


class InteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    typealias GestureConifg = () -> Void
    /**促发手势present的时候的config，config中初始化并present需要弹出的控制器*/
    var presentConifg: GestureConifg?
    
    /**促发手势push的时候的config，config中初始化并push需要弹出的控制器*/
    var pushConifg: GestureConifg?
    
    /**记录是否开始手势，判断pop操作是手势触发还是返回键触发*/
    var interation = false
    
    private var vc: UIViewController?
    /**手势方向*/
    private var direction: InteractiveTransitionGestureDirection?
    /**手势类型*/
    private var type: InteractiveTransitionType
    
    init(_ type: InteractiveTransitionType, _ direction: InteractiveTransitionGestureDirection) {
        self.type = type
        self.direction = direction
    }
    
    func addPanGesgureFor(vc: UIViewController){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(panGesture:)))
        self.vc = vc
        vc.view.addGestureRecognizer(pan)
    }
    
    @objc func handleGesture(panGesture: UIPanGestureRecognizer) {
        guard let panView =  panGesture.view else { return }
        var persent: CGFloat = 0
        switch direction {
        case .left:
            let transitionX = -(panGesture.translation(in: panView).x)
            persent = transitionX / panView.frame.size.width
        case .right:
            let transitionX = panGesture.translation(in: panView).x
            persent = transitionX / panView.frame.size.width
        case .up:
            let transitionY = -(panGesture.translation(in: panView).y)
            persent = transitionY / panView.frame.size.width
        case .down:
            let transitionY = panGesture.translation(in: panView).y
            persent = transitionY / panView.frame.size.width
        case .none:
            break
        }
        
        switch panGesture.state {
        case .began:
            interation = true
            startGesture()
        case .changed:
            update(persent)
        case .ended:
            interation = false
            if persent > 0.5 {
                finish()
            }else{
                cancel()
            }
        default:
            break
        }
    }
    
    private func startGesture(){
        switch type {
        case .present:
            presentConifg?()
        case .dismiss:
            self.vc?.dismiss(animated: true, completion: nil)
        case .push:
            pushConifg?()
        case .pop:
            self.vc?.navigationController?.popViewController(animated: true)
        }
    }
    
}
