//
//  SelectAlert.swift
//  JHPhotos
//
//  Created by winter on 2019/12/26.
//  Copyright © 2019 DJ. All rights reserved.
//

import UIKit

fileprivate let jp_screenWidth = UIScreen.main.bounds.width
fileprivate let jp_screenHeight = UIScreen.main.bounds.height
// 刘海屏系列
fileprivate let jp_iPhoneXs = Int(100 * jp_screenHeight / jp_screenWidth) == 216
// 底部button距离
let jp_bottomSpace: CGFloat = jp_iPhoneXs ? 34 : 0
// 顶部导航栏高度
let jp_navBarHeight: CGFloat = jp_iPhoneXs ? 88 : 64

enum AlertActionType {
    case `default`
    case cancel
}

typealias AlertActionClosure = ()->Void
struct SelectAlertAction {
    var title: String
    var action: AlertActionClosure?
    var type: AlertActionType
    var textColor: UIColor
    
    init(title: String, type: AlertActionType = .default, titleColor: UIColor = UIColor(hexString: "#1D2129"), action: AlertActionClosure? = nil) {
        self.title = title
        self.type = type
        self.action = action
        self.textColor = titleColor
    }
}

/// 仿微信 底部弹起选择
class SelectAlert: UIView {
    
    fileprivate var alertTitle = ""
    
    fileprivate let alertTitleHeight: CGFloat = 54
    fileprivate let viewSpace: CGFloat = 8
    fileprivate var selectActionCount: CGFloat = 0
    fileprivate let selectActionHeight: CGFloat = 54
    
    fileprivate let lineColor = UIColor(hexString: "#F2F3F5")
//    fileprivate var textColor = UIColor(hexString: "#1D2129")
    
    fileprivate lazy var selectView: UIView = {
        let view = UIView(frame: frame)
        return view
    }()
    
    fileprivate lazy var coverView: UIControl = {
        let view = UIControl(frame: CGRect(x: 0, y: 0, width: jp_screenWidth, height: jp_screenHeight))
        view.backgroundColor = UIColor.black
        view.alpha = 0
        return view
    }()
    
    init(alertTitle: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: jp_screenWidth, height: jp_screenHeight))
        self.alertTitle = alertTitle
        
        setupSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: jp_screenWidth, height: jp_screenHeight))
        setupSubviews()
    }
    
    private func setupSubviews() {
        coverView.addTarget(self, action: #selector(hide), for: .touchUpInside)
        self.addSubview(coverView)
        self.addSubview(selectView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var selectAction: SelectAlertAction?
    fileprivate var deleteAction: SelectAlertAction?
    fileprivate var actions: [SelectAlertAction] = []
    public func addAction(_ action: SelectAlertAction) {
        if action.type == .cancel {
            actions = actions.reversed()
            actions.insert(action, at: 0)
            deleteAction = action
        }
        else {
            actions.append(action)
        }
        selectActionCount += 1
    }
    
    public func show() {
        setupActions()
        
        if let window = UIApplication.shared.keyWindow {
            window.endEditing(true)
            window.addSubview(self)
            
            self.setFrameY(y: 0)
            let y = jp_screenHeight - selectView.frame.height
            let frame = CGRect(origin: CGPoint(x: 0, y: y), size: selectView.frame.size)
            UIView.animate(withDuration: 0.25, animations: {
                self.selectView.frame = frame
                self.coverView.alpha = 0.3
            })
        }
    }
}

fileprivate extension SelectAlert {
    
    func handleSelectImageDatas(_ datas: [JPhoto]) {
        selectAction?.action?()
        self.removeFromSuperview()
    }
    
    func setFrameY(y: CGFloat) {
        var frame = self.frame
        frame.origin.y = y
        self.frame = frame
    }
    
    func hideAndRemove(_ remove: Bool = true, finished: @escaping ()->Void) {
        let y = selectActionHeight * selectActionCount + viewSpace + selectView.frame.minY
        let frame = CGRect(origin: CGPoint(x: 0, y: y), size: selectView.frame.size)
        UIView.animate(withDuration: 0.25, animations: {
            self.selectView.frame = frame
            self.coverView.alpha = 0
        }) { (_) in
            if remove {
                self.removeFromSuperview()
            }
            else {
                self.setFrameY(y: jp_screenHeight)
            }
            finished()
        }
    }
    
    func selectViewItem(_ frame: CGRect, showLine: Bool, textColor: UIColor) -> UIButton {
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.white
        
        let button = UIButton(type: .custom)
        button.frame = view.bounds
        button.setTitleColor(textColor, for: .normal)
        button.setTitleColor(textColor.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .white
        
        view.addSubview(button)
        
        if showLine {
            let line = UIView(frame: CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5))
            line.backgroundColor = lineColor
            view.addSubview(line)
        }
        
        selectView.addSubview(view)
        return button
    }
    
    func setupActions() {
        setSelectBgView()
        
        let count = actions.count
        actions = actions.reversed()
        for (i, item) in actions.enumerated() {
            var y = CGFloat(i) * selectActionHeight + alertTitleHeight
            let height = selectActionHeight
            if i == count - 1 {
                let line = UILabel(frame: CGRect(x: 0, y: y, width: kScreenWidth, height: viewSpace))
                line.backgroundColor = UIColor(hexString: "#F2F3F5")
                selectView.addSubview(line)
                y += viewSpace
            }
            let itemFrame = CGRect(x: 0, y: y, width: jp_screenWidth, height: height)
            let button = self.selectViewItem(itemFrame, showLine: i != count - 1, textColor: item.textColor)
            button.tag = i
            button.setTitle(item.title, for: .normal)
            button.addTarget(self, action: #selector(buttonClickedAction(_:)), for: .touchUpInside)
        }
    }
    
    func setSelectBgView() {
        let titleLabel = UILabel(text: alertTitle, font: SCFont(16), nColor: UIColor(hexString: "#86909C"))
        titleLabel.textAlignment = .center
        selectView.addSubview(titleLabel)
        let line = UIView(frame: CGRect(x: 0, y: alertTitleHeight - 0.5, width: frame.width, height: 0.5))
        line.backgroundColor = lineColor
        selectView.addSubview(line)
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: alertTitleHeight)
        
        let height: CGFloat = selectActionCount * selectActionHeight + viewSpace + jp_bottomSpace + alertTitleHeight
        let frame = CGRect(x: 0, y: jp_screenHeight, width: jp_screenWidth, height: height)
        selectView.frame = frame
        
        selectView.backgroundColor = .white
        
        let maskPath = UIBezierPath(roundedRect: selectView.bounds,
                                    byRoundingCorners: UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue),
                                    cornerRadii: CGSize(width: 10, height: 10))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = selectView.bounds
        maskLayer.path = maskPath.cgPath
        selectView.layer.mask = maskLayer
    }
}

@objc fileprivate extension SelectAlert {
    
    func hide() {
        hideAndRemove { [weak self] in
            self?.deleteAction?.action?()
        }
    }
    
    func buttonClickedAction(_ sender: UIButton) {
        let action = actions[sender.tag]
        hideAndRemove { action.action?() }
    }
}
