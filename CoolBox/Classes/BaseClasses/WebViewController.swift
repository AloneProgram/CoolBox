//
//  WebViewController.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: EViewController, PresentFromBottom,WebViewAction, EmptyPlaceholder {
    func responseJsHandler(_ type: String, body: Any) {
        
    }
    
    init(urlString: String) {
        var url = URL(string: urlString)
    
        // fix URL不变时，资源更新后，会出现白屏
        var components = URLComponents(string: urlString)
        let item = URLQueryItem(name: "time", value: "\(ENetworking.timestamp())")
        var queryItems: [URLQueryItem] = [item]
        if let items = components?.queryItems {
            queryItems.append(contentsOf: items)
        }
        components?.queryItems = queryItems
        url = components?.url
        
        self.webViewUrl = url
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var webViewUrl: URL?
    var webView: WKWebView!
    var shouldShowShare: Bool = false
    var webResponseJS = WebResponseJS()
    fileprivate var webViewOriginTitle: String?
    
    fileprivate lazy var loadingProgressView: UIProgressView = {
        let width = UIScreen.main.bounds.width
        let view = UIProgressView(frame: CGRect.zero)
        view.trackTintColor = UIColor.white
        view.progressTintColor = .black
        return view
    }()
    
    private var backButtonItem: UIBarButtonItem!
    private var closeButtonItem: UIBarButtonItem!
    private var webShareContent: String? = nil
    private var hideShare: Bool = false
    
    deinit {
        webView.removeObserver(self, forKeyPath: "URL")
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        
        webResponseJS.removeAllScriptMessageHandler()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "loading..."
        
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.userContentController = webResponseJS
        config.mediaTypesRequiringUserActionForPlayback = .video
        webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        view.addSubview(loadingProgressView)
        
        loadingProgressView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(2)
        }
        
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        setupNavBarItems()
        
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        if let url = webViewUrl {
            let request = URLRequest(url: url)
            webView.load(request)
            addUserAgent(url.absoluteString)
            addUserAgent(url.absoluteString)
        }
        
        addJSHandler()
    }
    
    // MARK: - observeValueForKeyPath
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {
            if keyPath == "title" {
                if let title = change?[.newKey] as? String {
                    webViewOriginTitle = title
                    if title.count > 10 {
                        let string = title as NSString
                        let str = string.substring(to: 8)
                        self.title = str + "..."
                    }
                    else {
                        self.title = title
                    }
                }
            }
            else if keyPath == "estimatedProgress" {
                if let progress = change?[.newKey] as? Float {
                    loadingProgressView.progress = progress
                    if progress >= 1.0 {
                        _ = delay(0.3, task: { [weak self] in
                            self?.loadingProgressView.isHidden = true
                        })
                    }
                }
            }
            else if keyPath == "URL" {
                if let url = change?[.newKey] as? URL, let webUrl = webViewUrl,
                    url != webUrl {
                    webViewUrl = url
                    webShareContent = nil
                }
            }
        }
    }
    
    // MARK: - WebViewAction
    func addJSHandler() {
        webResponseJS.addJSHandler { [weak self] (type, body) in
            self?.jsHandler(type, body: body)
        }
    }
    
    func addWebResponseJS(_ webResponse: WebResponseJS, linkStr: String) {
        #if RELEASE
        guard linkStr.contains("yuecan") else { return }
        #endif
        addScriptMessageHandlerForTrackH5()
        addScriptMessageHandlerForExitLogin()
        addScriptMessageHandlerForOther()
        if shouldShowShare { addScriptMessageHandlerForShare() }
    }
    
    
    // MARK: - net error show empty
    func dealNetWorkingError() {
        showEmptyView { [weak self] in
            if self?.webView.url != nil {
                self?.webView.reload()
            }
            else if let url = self?.webViewUrl {
                self?.webView.load(URLRequest(url: url))
            }
        }
    }
}

fileprivate extension WebViewController {
    
    func dealTrackH5Data(_ body: Any) {
        guard let body = body as? String else { return }
  
    }
}

fileprivate extension WebViewController {
    
    func setupNavBarItems() {
        
        let normalColor = UIColor.black
        let highlightedColor = UIColor.black.withAlphaComponent(0.5)
        let font = SCMediumFont(18)
//        let leftEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        let backButton = UIButton(type: .custom)
        backButton.setTitle("返回", for: .normal)
        backButton.titleLabel?.font = font
        backButton.setTitleColor(normalColor, for: .normal)
        backButton.setTitleColor(highlightedColor, for: .highlighted)
//        backButton.titleEdgeInsets = leftEdgeInsets
        backButton.setImage(UIImage(named: "ic_backArrow"), for: .normal)
//        backButton.imageEdgeInsets = leftEdgeInsets
        backButton.addTarget(self, action: #selector(buttonClickedAction(_:)), for: .touchUpInside)
        backButton.sizeToFit()
        backButtonItem = UIBarButtonItem(customView: backButton)
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.titleLabel?.font = font
        closeButton.setTitleColor(UIColor.black, for: .normal)
        closeButton.addTarget(self, action: #selector(buttonClickedAction(_:)), for: .touchUpInside)
        closeButton.tag = 100
        closeButton.sizeToFit()
        closeButtonItem = UIBarButtonItem(customView: closeButton)
        

        
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationItem.leftBarButtonItems = [backButtonItem]
    }
    
    func webViewLinkLoad(_ linkStr: String?) -> Bool {
        guard let linkStr = linkStr else {
            return false
        }
        addWebResponseJS(webResponseJS, linkStr: linkStr)
        return true
    }
    
    func updateNavigationItems() {
        if webView.canGoBack {
            navigationItem.setLeftBarButtonItems([backButtonItem, closeButtonItem], animated: false)
        }
        else {
            navigationItem.setLeftBarButtonItems([backButtonItem], animated: false)
        }
    }
    
    func hideShareButton(_ isHidden: Bool) {
        hideShare = isHidden
        navigationItem.rightBarButtonItem?.customView?.isHidden = isHidden
    }
    
    func addUserAgent(_ linkStr: String) {
        #if RELEASE
        guard linkStr.contains("yuecan") else { return }
        #endif
        let customUserAgent = getAppVersion()
        webView.evaluateJavaScript("navigator.userAgent") { [weak self] (result, error) in
            guard let ua = result as? String else { return }
            self?.webView.customUserAgent = "\(ua) huandian/\(customUserAgent)"
        }
    }
    
    func getAppVersion() -> String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return version
        }
        else {
            return "unkown"
        }
    }
    
    func jsHandler(_ type: String, body: Any) {

    }
    
    func webShareContent(_ body: String? = nil) {
        guard let content = body else { return }
        webShareContent = content
    }
}

@objc extension WebViewController {
    
    func buttonClickedAction(_ sender: UIButton) {
        if sender.tag != 100 {
            if webView.canGoBack {
                webView.goBack()
                return
            }
        }
        
        // 兼容 dismiss & pop
        guard let nav = navigationController else {
            dismiss(animated: true)
            return
        }
        if nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        }
        else {
            dismiss(animated: true)
        }
    }
    
    func shareAction() {

    }
}

// MARK: - WKNavigationDelegate WKUIDelegate
extension WebViewController: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let linkStr = navigationAction.request.url?.absoluteString
        var actionPolicy: WKNavigationActionPolicy = .allow
        if !webViewLinkLoad(linkStr) {
            actionPolicy = .cancel
        }
        decisionHandler(actionPolicy)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingProgressView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateNavigationItems()
        hideShareButton(hideShare)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation = \(error)")
        title = ""
        loadingProgressView.isHidden = true
        dealNetWorkingError()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        completionHandler()
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}

// MARK: - WebViewAction
protocol WebViewAction {
    /// 添加 js 回调APP 处理
    func addJSHandler()
    
    /// 添加 js hook
    func addWebResponseJS(_ webResponse: WebResponseJS, linkStr: String)
    
    /// 添加 js 回调APP 处理
    func responseJsHandler(_ type: String, body: Any)
}

//extension WebViewAction {
//    func responseJsHandler(_ type: String, body: Any) {}
//}

private enum JSHandlerType: String {
    case unkown
    case trackH5 = "onEvent"
    case exitLogin = "exitLogin"
    
    case webShare = "share"
    case showShare = "showShare"
    case hideShare = "hideShare"
    case shareData = "updateAppMessageShareData"
    
    case openBrowser = "openBrowser"
}

private extension WebViewController {
    // H5 分享
    func addScriptMessageHandlerForShare() {
        webResponseJS.addScriptMessageName(JSHandlerType.webShare.rawValue)
        webResponseJS.addScriptMessageName(JSHandlerType.showShare.rawValue)
        webResponseJS.addScriptMessageName(JSHandlerType.hideShare.rawValue)
        webResponseJS.addScriptMessageName(JSHandlerType.shareData.rawValue)
    }
    
    // web端401
    func addScriptMessageHandlerForExitLogin() {
        webResponseJS.addScriptMessageName(JSHandlerType.exitLogin.rawValue)
    }
    
    // h5 埋点
    func addScriptMessageHandlerForTrackH5() {
        webResponseJS.addScriptMessageName(JSHandlerType.trackH5.rawValue)
    }
    
    func addScriptMessageHandlerForOther() {
        webResponseJS.addScriptMessageName(JSHandlerType.openBrowser.rawValue)
    }
}

