//
//  PresentBottomVC.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

import Foundation
import UIKit

protocol PresentBottomVCProtocol {
    var controllerHeight: CGFloat {get}
    var backgroundColorAlphaComponent: CGFloat {get}
    
    // 当前alert是否将要dismiss
    var willDismiss: Bool {get}
}

class PresentBottomVC: UIViewController, PresentBottomVCProtocol {
    
    var controllerHeight: CGFloat {
        return 0
    }
    
    var backgroundColorAlphaComponent: CGFloat {
        return 0.3
    }
    
    var enableTouchToDismiss: Bool {
        return true
    }
    
    var willDismiss: Bool {
        return shouldDismiss
    }
    private var  shouldDismiss: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(presentBottomShouldHide(_:)), name: NSNotification.Name(PresentBottomHideKey), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(PresentBottomHideKey), object: nil)
    }
    
    @objc func presentBottomShouldHide(_ some: Any?) {
        guard let noti = some as? NSNotification,
            let placeholder = noti.object as? String,
            placeholder == "placeholder" else {
            shouldDismiss = true
            return self.dismiss(animated: true, completion: nil)
        }
        if enableTouchToDismiss {
            shouldDismiss = true
            self.dismiss(animated: true, completion: nil)
        }
    }
}

let PresentBottomHideKey = "ShouldHidePresentBottom"
fileprivate class PresentBottom: UIPresentationController {
    
    lazy var blackView: UIControl = {
        let view = UIControl()
        if let frame = self.containerView?.bounds {
            view.frame = frame
        }
        view.backgroundColor = UIColor.black.withAlphaComponent(self.backgroundColorAlphaComponent)
        view.addTarget(self, action: #selector(sendHideNotification), for: .touchUpInside)
        return view
    }()
    
    /// value to control height of bottom view
    var controllerHeight: CGFloat
    
    var backgroundColorAlphaComponent: CGFloat
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        // get height from an objec of PresentBottomVC class
        if case let vc as PresentBottomVC = presentedViewController {
            controllerHeight = vc.controllerHeight
            backgroundColorAlphaComponent = vc.backgroundColorAlphaComponent
        }
        else {
            controllerHeight = UIScreen.main.bounds.width
            backgroundColorAlphaComponent = 0.3
        }
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    /// add blackView to the container and let alpha animate to 1 when show transition will begin
    override func presentationTransitionWillBegin() {
        blackView.alpha = 0
        containerView?.addSubview(blackView)
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
        }
    }
    
    /// let blackView's alpha animate to 0 when hide transition will begin.
    override func dismissalTransitionWillBegin() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
        }
    }
    
    /// remove the blackView when hide transition end
    ///
    /// - Parameter completed: completed or no
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            blackView.removeFromSuperview()
        }
    }
    
    /// define the frame of bottom view
    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: UIScreen.main.bounds.height-controllerHeight, width: UIScreen.main.bounds.width, height: controllerHeight)
    }
    
    @objc func sendHideNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(PresentBottomHideKey), object: "placeholder")
    }
    
}

// MARK: - PresentBottomVC have this function
extension PresentBottomVC: UIViewControllerTransitioningDelegate {
    
    // function refers to UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let present = PresentBottom(presentedViewController: presented, presenting: presenting)
        return present
    }
}

// MARK: - add function for that PresentFromBottom
protocol PresentFromBottom: UIViewController {
    
    /// function to show the bottom view
    ///
    /// - Parameter tovc: a instance of PresentBottomVC
    func presentFromBottom(_ tovc: PresentBottomVC )
}

extension PresentFromBottom {
    func presentFromBottom(_ tovc: PresentBottomVC ){
        tovc.modalPresentationStyle = .custom
        tovc.transitioningDelegate = tovc
        self.present(tovc, animated: true, completion: nil)
    }
}
