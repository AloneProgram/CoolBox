//
//  GuidVC.swift
//  huandian
//
//  Created by Jhin on 2020/9/8.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

class GuidVC: EViewController, PresentToCenter, UIScrollViewDelegate {
    
    private var scrollview = UIScrollView()
    var clickCount = 0
    
    var ads: [String] = GlobalConfigManager.shared.systemoInfoConfig?.openScreenAds ??  ["https://oss.kubaoxiao.com/launch-image/1920-1080/1.jpg",  "https://oss.kubaoxiao.com/launch-image/1920-1080/2.jpg", "https://oss.kubaoxiao.com/launch-image/1920-1080/3.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hasShowAds = UserDefaults.standard.bool(forKey: "HasShowAds")
        
        setGuideImg()
        
        if !hasShowAds {
            UserDefaults.standard.set(true, forKey: "HasShowAds")
            scrollview.isPagingEnabled = true
            scrollview.contentSize = CGSize(width: CGFloat(ads.count) * kScreenWidth, height: kScreenHeight)
            scrollview.delegate = self
            let tap = UITapGestureRecognizer(target: self, action: #selector(clickScrollview))
            scrollview.addGestureRecognizer(tap)
            view.addSubview(scrollview)
            scrollview.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            ads.enumerated().forEach { idx, str in
                let imageView = UIImageView()
                imageView.kf.setImage(with: URL(string: str))
                imageView.contentMode = .scaleToFill
                scrollview.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.left.equalTo(CGFloat(idx) * kScreenWidth)
                    make.top.equalToSuperview()
                    make.size.equalTo(CGSize(width: kScreenWidth, height: kScreenHeight))
                }
            }
        }else {
            setRootViewController()
        }
       
    }
    
    @objc func clickScrollview() {
        
        if scrollview.contentOffset.x >= 2.0 * kScreenWidth {
            let alert = PrivacyProtocolAlert()
            presentToCenter(alert)
            return
        }

        clickCount += 1
        scrollview.setContentOffset(CGPoint(x: CGFloat(clickCount) * kScreenWidth, y: 0), animated: true)

    }
    
    func setGuideImg() {
        guard let launchImages = Bundle.main.infoDictionary?["UILaunchImages"] as? [Any] else { return }

        let viewSize = UIScreen.main.bounds.size
        let viewOrientation = "Portrait" //横屏请设置成 @"Landscape"
        var launchImage = ""

        for dict in launchImages {
            guard let dict = dict as? [AnyHashable : Any] else { continue }
            if let imageSizeString = dict["UILaunchImageSize"] as? String,
                let launchImageOrientation = dict["UILaunchImageOrientation"] as? String {
                let imageSize = NSCoder.cgSize(for: imageSizeString)
                if viewSize.equalTo(imageSize) && viewOrientation == launchImageOrientation {
                    launchImage = dict["UILaunchImageName"] as! String
                }
            }
        }

        let imagView = UIImageView(frame: view.bounds)
        imagView.image = UIImage(named: launchImage)
        imagView.backgroundColor = .red
        imagView.contentMode = .scaleAspectFill
        view.addSubview(imagView)
    }

    
    func setRootViewController() {
        let keyWindow = UIApplication.shared.delegate?.window
        if Login.isLogged() {
        //去除登陆限制，增加游客模式
            keyWindow??.rootViewController = AppTabBarController()
        }
        else {
            keyWindow??.rootViewController = LoginVC()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        clickCount = Int(offset.x / kScreenWidth)
    }
}
