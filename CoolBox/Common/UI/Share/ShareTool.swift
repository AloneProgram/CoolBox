//
//  ShareTool.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

public enum ShareScene: Int {
    case unkown = -1
    case local = 0
    case wx
    case qWx
    case dd
    case feishu
    case more
    
    var shareIcon: UIImage? {
        switch self {
        case .local:            return UIImage(named: "share_local")
        case .wx:        return UIImage(named: "share_wx")
        case .qWx:      return UIImage(named: "share_qWX")
        case .dd:            return UIImage(named: "share_dd")
        case .feishu:           return UIImage(named: "share_feishu")
        case .more:          return UIImage(named: "share_more")
        case .unkown:
            return nil
        }
    }
    
    var shareTitle: String {
        switch self {
        case .local:            return "保存到本地"
        case .wx:       return "微信"
        case .qWx:     return "企业微信"
        case .dd:           return "钉钉"
        case .feishu:          return "飞书"
        case .more:          return "更多"
        case .unkown:
            return ""
        }
    }
}
//分享内容拼接
public struct ShareContent {
    public var scene: ShareScene = .unkown
    public var title: String = ""
    public var imageUrl = ""
    public var shareUrl = ""
    public var description = ""
  
    public var viewController: UIViewController?
    public var completed: ((_ type: ShareScene) -> Void)? = nil
    public var shareScenes: [ShareScene] = [.wx, .qWx, .feishu, .dd, .more]
    
    public init() {}
}


//分享弹窗样式配置
public struct ShareUIConfig {
    //弹窗标题
    public var title = "Share"
    
    //圆角
    public var cornerRadius: CGFloat = 12
    
    public init(title: String, cornerRadius: CGFloat) {
        self.title = title
        self.cornerRadius = cornerRadius
    }
    
    public init() {}
    
}

 class ShareTool: NSObject {
    
    public static var share: ShareTool {
       struct Singleton {
           static let instance = ShareTool()
       }
       let instance = Singleton.instance

       return instance
    }
    
    private var completed: ((_ type: ShareScene) -> Void)?
    

     static func `do`(_ content: ShareContent, config: ShareUIConfig? = nil, at vc: PresentFromBottom) {
        let share = ShareViewController(content, shareUIConfig: config)
        vc.presentFromBottom(share)
    }
    
    fileprivate static func start(_ content: ShareContent) {
        switch content.scene {
        case .wx:
            ShareTool.share.shareWX(content: content)
        case .more:
            ShareTool.share.shareMore(content: content)
        case .qWx:
            ShareTool.share.shareQWX(content: content)
        case .dd:
            ShareTool.share.shareDD(content: content)
        case .feishu:
            ShareTool.share.shareFeishu(content:content)
        case .local:
            ShareTool.share.shareLocal(content:content)
        default:
            break
        }
    }

    public func shareMore( content: ShareContent) {
        if let vc = content.viewController {
            let title = content.title
            guard let url = URL(string: content.shareUrl) else { return }
            let items: [Any] = [title, url]
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll]
            vc.present(activityVC, animated: true, completion: nil)
            activityVC.completionWithItemsHandler = { _, success, _, _ in
                activityVC.dismiss(animated: true)
                if success {
                    content.completed?(.more)
                }
            }
        }
    }
     
     func shareLocal(content: ShareContent) {
         guard let url = URL(string: content.shareUrl) else { return }
         let picker = UIDocumentPickerViewController(url: url, in: .exportToService)
         picker.modalPresentationStyle = .formSheet
         content.viewController?.present(picker, animated: true)
         
//         let configuration = URLSessionConfiguration.default
//         let session = URLSession(configuration: configuration)
//
//         var fillPath = ""
//
//         let request = URLRequest(url: url)
//         let downTask = session.downloadTask(with: request) {location, respons, error in
//
//
//           do {
//               //输出下载文件原来的存放目录
//                //location位置转换
//                let locationPath = location!.path
//
//
//                //拷贝到用户目录
//                let documnets:String = NSHomeDirectory() + "\(Date().timeIntervalSince1970).pdf"
//                //创建文件管理器
//                let fileManager = FileManager.default
//               try fileManager.copyItem(atPath: locationPath, toPath: documnets)
//                   fillPath = documnets
//                  print("new location:\(documnets)")
//
//               DispatchQueue.main.async {
//                   if let filPath = URL(string: "file://\(fillPath)") {
//                       let picker = UIDocumentPickerViewController(url: filPath, in: .exportToService)
//                       picker.modalPresentationStyle = .formSheet
//                       content.viewController?.present(picker, animated: true)
//                   }
//               }
//
//           }catch  {
//               print(123)
//           }
//         }
//
//            //使用resume方法启动任务
//         downTask.resume()
     }
    
     
     func shareWX(content: ShareContent) {
         guard WXApi.isWXAppInstalled() else {
             return EToast.showInfo("未安装《微信》")
         }
         
         let object = WXWebpageObject()
         object.webpageUrl = content.shareUrl

         let message = WXMediaMessage()
         message.title = content.title
         message.description = content.description
         message.mediaObject = object

         let req = SendMessageToWXReq()
         req.bText = false
         req.message = message
         
         if let image = UIImage(named: "AppIcon") {
             ImageDownloader.compressImageQuality(image, toKByte: 10) { data in
                 DispatchQueue.main.async {
                     message.thumbData = data
                     WXApi.send(req)
                 }
             }
         }
     }
     
     func shareQWX( content: ShareContent) {
         
     }
     
     func shareFeishu( content: ShareContent) {
         
     }
     
     func shareDD( content: ShareContent) {
         
     }
  
}

fileprivate class ShareViewController: PresentBottomVC {
    
    var kScreenWidth: CGFloat = UIScreen.main.bounds.width
    var kBottomSpace: CGFloat {
        let iPhoneXs = Int(100 * UIScreen.main.bounds.height / UIScreen.main.bounds.width) == 216
        return iPhoneXs ? 34 : 0
    }
    
    private var shareItems: [ShareScene] = []
    private var shareUIConfig = ShareUIConfig(title: "", cornerRadius: 12)
    
    override var controllerHeight: CGFloat {
        return 228 + kBottomSpace
    }
    
    private var content: ShareContent
    init(_ content: ShareContent, shareUIConfig: ShareUIConfig? = nil) {
        self.content = content
        self.shareItems = content.shareScenes
        if let c = shareUIConfig {
            self.shareUIConfig = c
        }
        
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
        
        let maskPath = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: shareUIConfig.cornerRadius, height: shareUIConfig.cornerRadius))
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer

        let contentView = UIView()
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(controllerHeight)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = shareUIConfig.title
        titleLabel.font = UIFont(name: "Helvetica-Bold", size: 16)
        titleLabel.textColor =  UIColor(hexString: "#1D2129")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(16)
        }
    
        let layout = UICollectionViewFlowLayout()
        let wid = (kScreenWidth - 24) / CGFloat(shareItems.count)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: wid, height: 80)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.register(ShareViewItem.self, forCellWithReuseIdentifier: "ShareViewItem")
        collectionView.delegate = self
        collectionView.dataSource = self
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(112)
        }
        collectionView.reloadData()
        
        let line = UILabel()
        line.backgroundColor = UIColor(hexString: "#F2F3F5")
        contentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.centerX.equalToSuperview()
            make.height.equalTo(10)
            make.top.equalTo(collectionView.snp.bottom)
        }
        
        let cancleBtn = UIButton(type: .custom)
        cancleBtn.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        cancleBtn.setTitle("取消", for: .normal)
        cancleBtn.setTitleColor(UIColor(hexString: "#1D2129"), for: .normal)
        cancleBtn.titleLabel?.font = Font(16)
        contentView.addSubview(cancleBtn)
        cancleBtn.snp.makeConstraints { (make) in
            make.left.centerX.equalToSuperview()
            make.height.equalTo(54)
            make.top.equalTo(line.snp.bottom)
        }
    }
    
    @objc func dismissAction() {
        dismiss(animated: true)
    }
}

extension ShareViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shareItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareViewItem", for: indexPath) as! ShareViewItem
        cell.type = shareItems[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        content.scene = shareItems[indexPath.row]
        let share = content
        dismiss(animated: true) { ShareTool.start(share) }
    }
}

fileprivate class ShareViewItem: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    var type: ShareScene = .unkown {
        didSet {
            imageView.image = type.shareIcon
            titleLabel.text = type.shareTitle
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.size.equalTo(CGSize(width: 52, height: 52))
            make.centerX.equalToSuperview()
        }
        
        titleLabel.font = UIFont(name: "Helvetica", size: 12)
        titleLabel.textColor = UIColor(hexString: "#86909C")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}

fileprivate extension String {
    func urlEncoded() -> String {
        let mstring = self.replacingOccurrences(of: " ", with: "+")
           let set = CharacterSet(charactersIn: "!*'\"();:@&=+$,/?%#[]% ")
           return mstring.addingPercentEncoding(withAllowedCharacters: set) ?? ""
    }
}

