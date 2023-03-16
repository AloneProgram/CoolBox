//
//  GuidVC.swift
//  huandian
//
//  Created by Jhin on 2020/9/8.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

class GuidVC: EViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGuideImg()
        
        setRootViewController()
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
}
