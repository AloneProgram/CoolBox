//
//  WebResponseJS.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit
import WebKit

class WebResponseJS: WKUserContentController, WKScriptMessageHandler {
    
    typealias JSHandlerClosure = (_ type: String, _ body: Any) -> Void
    private var jsHandler: JSHandlerClosure?
    var jsNames: [String] = []
    
    func addJSHandler(_ h: @escaping JSHandlerClosure) {
        jsHandler = h
    }
    
    /// 移除 js hander name
    func removeAllScriptMessageHandler() {
        for name in jsNames {
            removeScriptMessageHandler(forName: name)
        }
        removeAllUserScripts()
    }
    
    /// 添加 js hander name
    func addScriptMessageName(_ name: String) {
        if !jsNames.contains(name) {
            jsNames.append(name)
            add(self, name: name)
        }
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let name = message.name
        let body = message.body
        
        print("WKScriptMessageHandler name = \(name) \n body = \(body)")
        jsHandler?(name, body)
    }
}
