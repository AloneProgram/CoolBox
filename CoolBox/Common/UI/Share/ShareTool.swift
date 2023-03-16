//
//  ShareTool.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

enum ShareScene: Int {
//    WXSceneSession   = 0,   /**< 聊天界面    */
//    WXSceneTimeline  = 1,   /**< 朋友圈     */
    
    case unkown = -1
    case session = 0
    case timeline = 1
}

struct ShareContent {
    var scene: ShareScene = .unkown
    var title = ""
    var description = ""
    // 网页路径/应用路径/小程序路径
    var linkUrl = ""
    var imageUrl: URL?
    var imageData: Data?
    
    //小程序分享字段
    ///小程序的userName
    var userName = "gh_0c34197ebd6a"
    ///小程序的页面路径
    var path = ""
    ///小程序的类型，默认正式版
    var miniprogramType: WXMiniProgramType = .release
    
    init(title: String? = "", description: String = "", linkUrl: String = "", imageUrl: String? = "", path: String = "", hdImageData: Data? = nil) {
        self.title = title ?? ""
        
        self.linkUrl = linkUrl
        if description == "" {
            self.description = description
        }
        else {
            self.description = linkUrl
        }
        
        if let url = imageUrl{
            self.imageUrl = URL(string: url)
        }
        
        
        self.path = path
        
        #if RELEASE  //生产环境
            miniprogramType = .release
        #else  //测试环境
            miniprogramType = .preview
        #endif
        
    }
    
    init(json: JSON) {
        title = json["title"].stringValue
        description = json["desc"].stringValue
        imageUrl = URL(string: json["imgUrl"].stringValue)
        linkUrl = json["link"].stringValue
    }
}

struct ShareTool {
    static func `do`(_ content: ShareContent, at vc: PresentFromBottom) {
        let share = ShareViewController(content)
        vc.presentFromBottom(share)
    }
    
    fileprivate static func start(_ content: ShareContent) {
        guard WXApi.isWXAppInstalled() else {
            return EToast.showInfo("未安装《微信》")
        }
        
        let object = WXMiniProgramObject()
        object.webpageUrl = content.linkUrl
        object.userName = content.userName
        object.path = content.path
        object.hdImageData = content.imageData
        object.miniProgramType = content.miniprogramType
        object.withShareTicket = false

//            let webPage = WXWebpageObject()
//            webPage.webpageUrl = //content.linkUrl

        let message = WXMediaMessage()
        message.title = content.title
        message.description = content.description
        message.mediaObject = object

        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(content.scene.rawValue)

        let doShare: (Data?) -> Void = { (data) in
            message.thumbData = data
            WXApi.send(req)
        }
        
        if let url = content.imageUrl {
            ImageDownloader.loadData(url: url, maxKByte: 32, result: doShare)
        }
        else {
            doShare(content.imageData)
        }
    }
}

fileprivate class ShareViewController: PresentBottomVC {
    override var controllerHeight: CGFloat {
        return 140 + kBottomSpace
    }
    
    private var content: ShareContent
    init(_ content: ShareContent) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubview()
    }
}

extension ShareViewController {
    func setupSubview() {
        let contentView = UIView()
        contentView.backgroundColor = .white
        let radius: CGFloat = 24
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        contentView.layer.mask = mask
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(controllerHeight)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "分享至"
        titleLabel.font = MediumFont(14)
        titleLabel.textColor = UIColor(hexValue: 0x333333)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(12)
        }
        
        let sessionButton = ShareViewItem(title: "微信好友", imageName: "")
        sessionButton.tag = 100
        sessionButton.addTarget(self, action: #selector(doSahre(_:)), for: .touchUpInside)
        
        contentView.addSubview(sessionButton)
        sessionButton.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.size.equalTo(CGSize(width: 100, height: 70))
            make.centerX.equalToSuperview()
        }
        
//        let timelineButton = ShareViewItem(title: "微信朋友圈", imageName: R.image.icon_wx_timeline.name)
//        timelineButton.tag = 101
//        timelineButton.addTarget(self, action: #selector(doSahre(_:)), for: .touchUpInside)
//
//        contentView.addSubview(timelineButton)
//        timelineButton.snp.makeConstraints { (make) in
//            make.top.equalTo(sessionButton)
//            make.size.equalTo(CGSize(width: 100, height: 70))
//            make.centerX.equalToSuperview().multipliedBy(1.5).offset(-30)
//        }
    }
}

fileprivate class ShareViewItem: UIControl {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    
    init(title: String?, imageName: String) {
        super.init(frame: .zero)
        
        imageView.image = UIImage(named: imageName)
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.centerX.equalToSuperview()
        }
        
        titleLabel.text = title
        titleLabel.font = Font(12)
        titleLabel.textColor = UIColor(hexValue: 0x333333)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc extension ShareViewController {
    func doSahre(_ sender: UIView) {
        if sender.tag == 100 {
            // 好友
            content.scene = .session
        }
        else {
            // 朋友圈
            content.scene = .timeline
        }
        
        let share = content
        dismiss(animated: true) { ShareTool.start(share) }
    }
}
