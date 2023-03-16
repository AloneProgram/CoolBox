//
//  AppTabBarController.swift
//  huandian
//
//  Created by Jhin on 2020/9/8.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

//采用自定义itemview 方便后期扩展后台配置修改tabbaer image、badge
class AppTabBarController: BaseTabBarController {
    var itemsArr: [ItemView] = []
    
    //写死，可拓展为后台配置数据
    let titles = ["发票","报销","审批", "我的"]
    var items: [TabbarItem] = []
    
    // MARK: - 懒加载
   private lazy var composeBtn : UIButton = {
       // 初始化按钮
        let composeBtn = UIButton()
        composeBtn.setImage(UIImage(named: "img_tabadd"), for: .normal)
        composeBtn.setImage(UIImage(named: "img_tabadd"), for: .highlighted)
        composeBtn.addTarget(self, action: #selector(touchPostBtn), for: .touchUpInside)
        composeBtn.sizeToFit()
        return composeBtn
   }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titles.enumerated().forEach { (idx, title) in
            var item = TabbarItem()
            item.title = title
            item.norImageName = "ic_\(idx)_unsel"
            item.selImageName = "ic_\(idx)_sel"
            items.append(item)
        }
        
        delegate = self
        setupContentViews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 基础设置
    /// tabbar对应的视图控制器
    func setupContentViews() {
        tabBar.tintColor = .white
        tabBar.barTintColor =  .white
//        tabBar.isTranslucent = false // 关闭毛玻璃效果
        // 设置分割线
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        // 设置阴影
        tabBar.backgroundColor = .white
        tabBar.layer.shadowColor = UIColor.lightGray.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBar.layer.shadowOpacity = 0.15
        
        itemsArr.forEach { (item) in
            item.removeFromSuperview()
        }
        itemsArr.removeAll()
        
        viewControllers = items.enumerated().map { (index, item) -> UIViewController in
            itemsArr.append(setupTabbarItem(item, index: index))
            return setupTabbarSubController(index: index)
        }
        
        tabBar.addSubview(composeBtn)
        composeBtn.frame = CGRect(x: (kScreenWidth - 50)/2, y: -9, width: 50, height: 50)
        
        selecIdx = 0
    }
    
    func setupTabbarItem(_ tabItem: TabbarItem, index: Int) -> ItemView {
        let width: CGFloat = kScreenWidth / CGFloat(titles.count + 1)
        let height: CGFloat = iPhoneXs ? 49 : 55
        
        let item = ItemView(title: tabItem.title,
                                  nImgName: tabItem.norImageName,
                                  sImgName: tabItem.selImageName,
                                  normalTextColor: UIColor(hexString: "#4E5969"),
                                  selectedTextColor: UIColor(hexString: "#165DFF"))
        
        item.titleLabel?.font = SCFont(10)
        item.tag = index
        if index < 2 {
            item.frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: height)
        }else {
            item.frame = CGRect(x: CGFloat(index + 1) * width, y: 0, width: width, height: height)
        }
       
        item.addTarget(self,
                       action: #selector(onTouchItemView(_:)),
                       for: .touchUpInside)
        
        tabBar.addSubview(item)
        tabBar.bringSubviewToFront(item)
        
        return item
    }
    
    func setupTabbarSubController(index: Int) -> UIViewController {
        var vc: EViewController?
        switch index {
        case 0:
            vc = FPViewController()
        case 1:
            vc = BXViewController()
        case 2:
            vc = SPViewController()
        case 3:
            vc = MineViewController()
        default:
            vc = EViewController()
        }
        let nav = ENavigationController(rootViewController: vc!)
        nav.tabBarItem.tag = index
        return nav
    }
    
    @objc func onTouchItemView(_ sender: ItemView) {
        selecIdx = sender.tag
    }
    
    @objc func touchPostBtn() {
        ELog(message: "扫码导入")
        if let vc = viewControllers?[selecIdx].children.first {
//            vc.push(SendVideoVC())
        }
    }
    
    var selecIdx: Int = 0 {
        didSet {
            selectedIndex = selecIdx
            for item in itemsArr {
                item.isSelected = item.tag == selectedIndex
//                if item.isSelected {
//                    item.titleLabel?.font = MediumFont(12)
//                }else {
//                    item.titleLabel?.font = Font(12)
//                }
            }
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        selecIdx = item.tag
    }
    
}

extension AppTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        return true
    }
}


struct TabbarItem {
    var title = ""
    var norImageName = ""
    var selImageName = ""
}
