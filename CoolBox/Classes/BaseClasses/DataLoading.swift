//
//  DataLoading.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

enum DataLoadingPosition {
    case top
    case center
}

protocol DataLoading: UIViewController {
    func startLoading(_ load: @escaping ()->Void)
    func stopLoading()
    
    var position: DataLoadingPosition {get}
}

extension DataLoading {
    var position: DataLoadingPosition {
        get { return .center }
    }
    
    func startLoading(_ load: @escaping ()->Void) {
        guard let indicatorView = getActivityIndicator(position) else { return }
        view.bringSubviewToFront(indicatorView)
        indicatorView.startAnimating()
        load()
    }
    
    func stopLoading() {
        guard let indicatorView = getActivityIndicator(position) else { return }
        indicatorView.stopAnimating()
    }
}

fileprivate struct DataLoadingKey {
    static let rawValue = UnsafeRawPointer(bitPattern: "dataLoadingKey".hashValue)
}

fileprivate extension UIViewController {
    var activityIndicator: UIActivityIndicatorView? {
        set{
            guard let key = DataLoadingKey.rawValue else { return }
            if let obj = newValue {
                objc_setAssociatedObject(self, key, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get{
            guard let key = DataLoadingKey.rawValue else { return nil }
            return objc_getAssociatedObject(self, key) as? UIActivityIndicatorView
        }
    }
    
    func getActivityIndicator(_ position: DataLoadingPosition) -> UIActivityIndicatorView? {
        if let indicatorView = activityIndicator { return indicatorView }
        let indicatorView = UIActivityIndicatorView(style: .gray)
        indicatorView.stopAnimating()
        view.addSubview(indicatorView)
        switch position {
        case .center:
            indicatorView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        case .top:
            indicatorView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(50)
            }
        }
        
        activityIndicator = indicatorView
        return indicatorView
    }
}
