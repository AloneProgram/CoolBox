//
//  PresentCenterVC.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

protocol PresentCenterViewControllerProtocol {
    var controllerSize: CGSize { get }
    var needCustomContent: Bool { get }
    var enableTouchToDismiss: Bool { get }
}

let PresentCenterHideKey = "ShouldHidePresentCenterViewController"

class PresentCenterVC: UIViewController, PresentCenterViewControllerProtocol {
    
    var needCustomContent: Bool {
        return false
    }
    
    var enableTouchToDismiss: Bool {
        return false
    }
    
    var controllerSize: CGSize {
        return CGSize(width: 265, height: 285)
    }
    
    private var isPresenting = true
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(presentCneterShouldHide(_:)), name: NSNotification.Name(PresentCenterHideKey), object: nil)
        
        view.backgroundColor = .white
//        view.cornerRadius = 18
    }
    
    deinit {
        ELog(message: "PresentCenterVC deinit")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(PresentCenterHideKey), object: nil)
    }
    
    @objc func presentCneterShouldHide(_ some: Any?) {
        guard let noti = some as? NSNotification,
            let placeholder = noti.object as? String,
            placeholder == "placeholder" else {
                return self.dismiss(animated: true, completion: nil)
        }
        if enableTouchToDismiss {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - PresentCenterVC have this function
extension PresentCenterVC: UIViewControllerTransitioningDelegate {
    
    // function refers to UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let present = PresentCenter(presentedViewController: presented, presenting: presenting)
        return present
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
        
    }
}

extension PresentCenterVC: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresenting ? show(transitionContext) : hide(transitionContext)
    }
}

// Animate
fileprivate extension PresentCenterVC {
    func show(_ transitionContext: UIViewControllerContextTransitioning) {

        guard let presented = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? PresentCenterVC,
            let presentedView = presented.view else { return }
        let containerView = transitionContext.containerView

        let boundsSize = UIScreen.main.bounds.size
        let x = (boundsSize.width-controllerSize.width)/2
        let y = (boundsSize.height-controllerSize.height)/2
        let origin = CGPoint(x: x, y: y*0.8) // 上下留空，46分
        presentedView.frame = CGRect(origin: origin, size: controllerSize)
        presentedView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        containerView.addSubview(presentedView)

        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 20,
                       options: UIView.AnimationOptions.curveLinear,
                       animations: {
                        presentedView.transform = CGAffineTransform.identity
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }

    func hide(_ transitionContext: UIViewControllerContextTransitioning) {

        guard let dismissed = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let dismissedView = dismissed.view else { return }

        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration,
                       animations: {
                        dismissedView.alpha = 0
                        dismissedView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}

fileprivate class PresentCenter: UIPresentationController {
    
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
    
    deinit {
        ELog(message: "PresentCenter deinit")
    }
    
    /// add blackView to the container and let alpha animate to 1 when show transition will begin
    override func presentationTransitionWillBegin() {
        blackView.alpha = 0
        containerView?.addSubview(blackView)
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 1
        }
    }
    
    /// let blackView's alpha animate to 0 when hide transition will begin.
    override func dismissalTransitionWillBegin() {
        UIView.animate(withDuration: 0.3) {
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
    
    @objc func sendHideNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(PresentCenterHideKey), object: "placeholder")
    }
    
}

// MARK: - add function for that PresentToCenter
protocol PresentToCenter {
    
    /// function to show the center view
    ///
    /// - Parameter tovc: a instance of PresentCenterVC
    func presentToCenter(_ tovc: PresentCenterVC)
}

extension PresentToCenter where Self: UIViewController {
    func presentToCenter(_ tovc: PresentCenterVC) {
        tovc.modalPresentationStyle = .custom
        tovc.transitioningDelegate = tovc
        self.present(tovc, animated: true, completion: nil)
    }
}
