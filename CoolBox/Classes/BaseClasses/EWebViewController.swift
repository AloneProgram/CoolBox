//
//  EWebViewController.swift
//  huandian
//
//  Created by Jhin on 2020/9/8.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

// 功能例如：H5 跳转原生页面等
class EWebViewController: WebViewController {
    override init(urlString: String) {
        super.init(urlString: urlString)
        //        if let userId = AccountManager.shared.getUserId(), urlString.contains("yuecan") {
        if urlString.contains("yuecan") {
            // 这里 将 # 转为 *，为了解决不能争取获取到对应的 query，或者 path etc...
            var tempUrl = urlString.replacingOccurrences(of: "#", with: "*")
            var components = URLComponents(string: tempUrl)
            //            let item = URLQueryItem(name: "userId", value: "\(userId)")
            let item = URLQueryItem(name: "userId", value: "userId")
            var queryItems: [URLQueryItem] = [item]
            if let items = components?.queryItems {
                queryItems.append(contentsOf: items)
            }
            components?.queryItems = queryItems
            if let temp = components?.url?.absoluteString {
                tempUrl = temp.replacingOccurrences(of: "*", with: "#")
                self.webViewUrl = URL(string: tempUrl)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

private enum JSHandlerType: String {
    case unkown
    case skip = "skip"
}

private extension EWebViewController {
    // H5 唤起 app
    func addScriptMessageHandlerForSkip() {
        webResponseJS.addScriptMessageName("skip")
    }
    
    func jsHandler(_ type: JSHandlerType?, body: Any) {
        switch type {
        case .skip:      let _ = canHandleUrl(body as? String)
        default: break
        }
    }
}
