//
//  EViewController.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit
import HBDNavigationBar

enum NavigationBarStyle {
    /// 白底黑字
    case whiteBackground
    /// 透明白字
    case transparentBackground

    
    // 导航栏字体图标颜色
    var tintColor: UIColor {
        switch self {
        case .whiteBackground:          return .black
        case .transparentBackground:    return .white
        }
    }
    
    // 导航栏背景色
    var barTintColor: UIColor {
        switch self {
        case .whiteBackground:          return .white
        case .transparentBackground:    return .clear
        }
    }
    
    // 导航栏样式
    var barStyle: UIBarStyle {
        switch self {
        case .whiteBackground:          return .default
        case .transparentBackground:    return .black
        }
    }
    
    var backIcon: UIImage? {
        switch self {
        case .whiteBackground:          return UIImage(named: "ic_backArrow")
        case .transparentBackground:    return UIImage(named: "ic_back_white")
        }
    }
}

class EViewController: UIViewController, ParamAdaptAction {
    /// 子类需要处理 ParamAdaptAgain.ActionType == do
    var actionAgain: ParamAdaptAgain?
    /// 暂存参数
    var viewPageParam: Any?
    func paramArriveAt(_ param: Any?) {
        viewPageParam = param
        actionAgain = actionAgainFrom(param)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("message: '\(self.classForCoder)' deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //FIXME: MobClick
//        MobClick.beginLogPageView(className())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //FIXME: MobClick
//        MobClick.endLogPageView(className())
    }
    
    // 设置导航栏颜色 默认是 白底黑字
    var navigationBarStyle: NavigationBarStyle { return .whiteBackground }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }
    
    var leftTitle: String = "" {
        didSet {
            let backBtn = LeftImageButton(type: .custom)
            backBtn.setImage(navigationBarStyle.backIcon, for: .normal)
            backBtn.setTitle(leftTitle, for: .normal)
            backBtn.titleLabel?.font = SCMediumFont(18)
            backBtn.setTitleColor(UIColor(hexString: "#1D2129"), for: .normal)
            backBtn.addTarget(self, action: #selector(customPopAction), for: .touchUpInside)
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EColor.viewBgColor
        setupNavigationBar()
    }
}


// public
extension EViewController {
    func setRightBarButtonItems(_ items: [UIBarButtonItem]?) {
        navigationItem.rightBarButtonItems = items
    }
    
    func popViewController(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    
    func popToRootViewController(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
    
    /// 弹出新页面的同时，将当前页面从导航栈中移除
    func removeCurrentAndPush(viewController: UIViewController, animated: Bool = true) {
        navigationController?.removeCurrentAndPush(viewController: viewController, animated: animated)
    }
    
    /// 弹出新页面的同时，将当前页面及之前指定个页面从导航栈中移除
    /// count: 从当前控制器开始算，移除
    func removeMoreAndPush(viewController: UIViewController, animated: Bool = true, count: Int) {
        navigationController?.removeMoreAndPush(viewController: viewController,
                                                animated: animated, count: count)
    }
    
    /// 移除所有，展示viewController
    func removeAllAndPush(viewController: UIViewController, animated: Bool = true) {
        navigationController?.removeAllAndPush(viewController: viewController, animated: animated)
    }
    
    @objc func customPopAction() {
        popViewController()
    }
}

// navigation bar
private extension EViewController {
    func setupNavigationBar() {
        guard let navigationController = navigationController else { return }
        
        let tintColor = navigationBarStyle.tintColor
        self.hbd_tintColor = tintColor
        self.hbd_titleTextAttributes = [NSAttributedString.Key.foregroundColor: tintColor]
        self.hbd_barTintColor = navigationBarStyle.barTintColor
        self.hbd_barStyle = navigationBarStyle.barStyle
        self.hbd_barShadowHidden = true
        self.hbd_barHidden = false
        if navigationBarStyle == .transparentBackground {
            self.hbd_barAlpha = 0
            self.hbd_setNeedsUpdateNavigationBar()
        }
        
        guard navigationController.viewControllers.count > 1 else { return }
        let backItem = UIBarButtonItem(image: navigationBarStyle.backIcon,
                                       style: .plain, target: self,
                                       action:  #selector(customPopAction))
        navigationItem.leftBarButtonItem = backItem
    }
}

private extension EViewController {

    // 子类需要处理 ParamAdaptAgain.ActionType == do
    func handleParamAdaptAgain() {
        guard let actionAgain = actionAgain else { return }
        guard actionAgain.actionType == .router else { return }
        let _ = canHandleUrl(actionAgain.actionParam)
    }
}

// MARK: - ELargeTitleViewController
class ELargeTitleViewController: EViewController {
    
    private let titleLabel: UILabel = UILabel()
    var largeTitle: String? {
        didSet{
            titleLabel.text = largeTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 可以解决 titleView 位置突变问题
        self.hbd_barImage = navigationBarStyle.barTintColor.image
        setupLargeTitle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let titleView = titleLabel.superview else { return }
        // 存在隐藏导航栏的情况
        guard titleView.superview != nil else { return }
        
        let size = titleView.frame.size
        titleView.snp.remakeConstraints { (make) in
            make.left.equalTo(8)
            make.bottom.equalTo(0)
            make.size.equalTo(size)
        }
    }
    
    private func setupLargeTitle() {
        let size: CGSize
        if let navigationBar = navigationController?.navigationBar {
            size = CGSize(width: navigationBar.bounds.width * 0.6, height: navigationBar.bounds.height)
        }
        else {
            size = CGSize(width: view.bounds.width * 0.6, height: 44)
            print("warning: has no navigationController.navigationBar")
        }
        
        let titleView = UIView()
        titleView.backgroundColor = .clear
        if #available(iOS 11, *) {
            titleView.snp.makeConstraints { make in
                make.size.equalTo(size)
            }
        } else {
            titleView.frame = CGRect(origin: .zero, size: size)
        }
        
        titleLabel.sizeToFit()
        titleLabel.font = MediumFont(16)
        titleLabel.textColor = UIColor(hexValue: 0x16193C)

        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottom.equalToSuperview()
            make.height.equalTo(size.height)
        }
        navigationItem.titleView = titleView
        
        titleLabel.text = largeTitle
    }
}

// MARK: - ETableViewController
class ETableViewController: EViewController, RefreshFor, CYLTableViewPlaceHolderDelegate {
    
    var tableViewStyle: UITableView.Style { return .plain }
    var tableView: UITableView!
    var pageIndex = 1
//    var dataSource: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: .zero, style: tableViewStyle)
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
        
    func loadData(_ block: RefreshResult?) {}
    func loadMoreDatas(_ block: RefreshResult?) {}
    
    ///要实现展示占位图，必须使用tableView.cyl_reloadData() 代替 tableView.reloadData()
    func makePlaceHolderView() -> UIView! {
        return UIView.blankMsgView("暂时没有数据")
    }
    
    func enableScrollWhenPlaceHolderViewShowing() -> Bool {
        return true
    }
}

// MARK: - ELargeTitleTableViewController
class ELargeTitleTableViewController: ELargeTitleViewController, RefreshFor {
    var tableView = UITableView(frame: .zero, style: .plain)
//    var dataSource: [Any] = []
    var viewModel: ListData?
    var pageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func loadData(_ block: RefreshResult?) {}
    func loadMoreDatas(_ block: RefreshResult?) {}
}

// MARK: - ENavigationController
class ENavigationController: HBDNavigationController {
    class func setup() {
        setupNavigationBar()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // 防止两次push
        if let top = topViewController, top.isEqual(viewController) { return }
        
        // 子页面隐藏 TabBar
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
//        modalPresentationStyle = .fullScreen
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        modalPresentationStyle = .fullScreen
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ENavigationController {

    class func setupNavigationBar() {
        let titleColor = UIColor(hexValue: 0x333333)
        
        let navigationBar = UINavigationBar.appearance()
        navigationBar.setBackgroundImage(UIColor.white.image, for: .default)
        navigationBar.tintColor = titleColor
        navigationBar.barTintColor = .white
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        
        let titleAttributes = [NSAttributedString.Key.foregroundColor: titleColor,
                               NSAttributedString.Key.font: MediumFont(18)]
        navigationBar.titleTextAttributes = titleAttributes
    }

}

// MARK: - remove and push
extension UINavigationController {
    
    /// 弹出新页面的同时，将当前页面从导航栈中移除
    func removeCurrentAndPush(viewController: UIViewController, animated: Bool = true) {
        removeMoreAndPush(viewController: viewController, animated: animated, count: 1)
    }
    
    /// 弹出新页面的同时，将当前页面及之前指定个页面从导航栈中移除
    /// count: 从当前控制器开始算，移除
    func removeMoreAndPush(viewController: UIViewController, animated: Bool = true, count: Int) {
        let originCount = viewControllers.count
        guard count > 0, count <= originCount else {
            pushViewController(viewController, animated: animated)
            return
        }
        
        var vcArray = Array(viewControllers.dropLast(count))
        vcArray.append(viewController)
        if vcArray.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        setViewControllers(vcArray, animated: animated)
    }
    
    /// 移除所有，展示viewController
    func removeAllAndPush(viewController: UIViewController, animated: Bool = true) {
        setViewControllers([viewController], animated: animated)
    }
}
