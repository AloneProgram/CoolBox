//
//  EmptyPlaceholder.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

protocol EmptyPlaceholder {
    
    typealias RetryClosure = ()->Void
    
    func dealNetWorkingError()
    func showEmptyView(_ retryAction: @escaping RetryClosure)
    func removeEmptyView()
}

extension EmptyPlaceholder where Self: UIViewController {
    func dealNetWorkingError() {}
    
    func removeEmptyView() {
        guard let emptyView = e_emptyView else { return }
        UIView.animate(withDuration: 0.2, animations: {
            emptyView.alpha = 0.0
        }) { (_) in
            emptyView.snp.removeConstraints()
            emptyView.removeFromSuperview()
        }
    }
    
    func showEmptyView(_ retryAction: @escaping RetryClosure) {
        if let emptyView = e_emptyView {
            UIView.animate(withDuration: 0.2, animations: {
                emptyView.alpha = 1.0
            }) { (_) in
                emptyView.isHidden = false
            }
        }
        else {
            let emptyView = ENetErrorView(closure: retryAction)
            e_emptyView = emptyView
            view.addSubview(emptyView)
            emptyView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}

fileprivate class ENetErrorView: UIView {
    private let imageView = UIImageView()
    private let tipLabel = UILabel()
    private let tipDesLabel = UILabel()
    private let retryButton = UIButton(title: "重试")
    
    var retryClosure: EmptyPlaceholder.RetryClosure?
    
    init(closure: @escaping EmptyPlaceholder.RetryClosure) {
        retryClosure = closure
        super.init(frame: .zero)
        backgroundColor = UIColor.white
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    @objc func buttonClick() {
        hide()
        retryClosure?()
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (_) in
            self.isHidden = true
        }
    }
}

extension ENetErrorView {
    func setupSubviews() {
        //TODO: 设置网络错误背景图
//        if let path = R.file.icon_empty_net_errorPng.path() {
//            imageView.image = UIImage(contentsOfFile: path)
//        }
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-120)
            make.size.equalTo(CGSize(width: 165, height: 94))
        }
        
        tipLabel.text = "网络错误"
        tipLabel.textAlignment = .center
        tipLabel.font = MediumFont(16)
        tipLabel.textColor = EColor.blackTextColor
        
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }
        
        tipDesLabel.text = "请检查网络连接后重试"
        tipDesLabel.textAlignment = .center
        tipDesLabel.font = Font(12)
        tipDesLabel.textColor = UIColor(hexString: "#808080")
        
        addSubview(tipDesLabel)
        tipDesLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipLabel.snp.bottom).offset(10)
        }
        
        addSubview(retryButton)
        retryButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipDesLabel.snp.bottom).offset(60)
            make.size.equalTo(CGSize(width: 215, height: 50))
        }
        retryButton.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
}

fileprivate struct EmptyViewKey {
    static let rawValue = UnsafeRawPointer(bitPattern: "EmptyViewKey".hashValue)
}

fileprivate extension UIViewController {
    var e_emptyView: ENetErrorView? {
        set{
            guard let key = EmptyViewKey.rawValue else { return }
            if let obj = newValue {
                objc_setAssociatedObject(self, key, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get{
            guard let key = EmptyViewKey.rawValue else { return nil }
            return objc_getAssociatedObject(self, key) as? ENetErrorView
        }
    }
}
