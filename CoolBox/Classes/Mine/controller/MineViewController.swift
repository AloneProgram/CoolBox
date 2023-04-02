//
//  MineViewController.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/15.
//

import UIKit

class MineViewController: EViewController {
    
    override var navigationBarStyle: NavigationBarStyle { return .transparentBackground }
    
    private var headerView = MineHeadView.instance()
    
    private var list: [[CommonInfoModel]] = [
        [
            CommonInfoModel(UIImage(named: "user"), leftText: "账号与安全", showRightArrow: true),
            CommonInfoModel(UIImage(named: "email"), leftText: "专属邮箱", rightText: Login.currentAccount().email)
        ],
        [
            CommonInfoModel(UIImage(named: "globe"), leftText: "当前组织", rightText: Login.currentAccount().companyName.length > 0 ? Login.currentAccount().companyName : "暂无组织", showRightArrow: true),
            CommonInfoModel(UIImage(named: "add_user"), leftText: "添加成员", showRightArrow: true)
        ],
        [
            CommonInfoModel(UIImage(named: "feedback"), leftText: "帮助与反馈", showRightArrow: true),
            CommonInfoModel(UIImage(named: "business"),  leftText: "商务合作", rightText: "bd@kubaoxiao.com"),
            CommonInfoModel(UIImage(named: "about"), leftText: "关于酷报销", rightText: "v 1.0.0", showRightArrow: true)
        ]
    ]
    
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "CommonInfoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommonInfoCell")
        tableView.estimatedRowHeight = 54
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MineApi.getUserInfo { [weak self] _ in
            self?.list[1][0] = CommonInfoModel(UIImage(named: "globe"), leftText: "当前组织", rightText: Login.currentAccount().companyName.length > 0 ? Login.currentAccount().companyName : "暂无组织", showRightArrow: true)
            self?.tableView.reloadData()
            self?.headerView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EColor.viewBgColor
        self.hbd_barHidden = true
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let tmpview = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 97))
        tmpview.backgroundColor = .clear
        tmpview.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.tableHeaderView = tmpview
        tableView.tableFooterView = UIView()
        headerView.clickBlock = { [weak self] in
            self?.pushToScanLogin()
        }
        
        let infoDictionary = Bundle.main.infoDictionary
        if let version :String = infoDictionary!["CFBundleShortVersionString"] as? String  {
            list[2][2].rightText = "v"+version
            tableView.reloadData()
        }
    }
}

//Action
extension MineViewController {
    func pushToScanLogin() {        
        push(QRScanViewController())
    }
}

extension MineViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommonInfoCell = tableView.dequeueReusableCell(withIdentifier: "CommonInfoCell", for: indexPath) as! CommonInfoCell
        cell.selectionStyle = .none
        cell.bindData(list[indexPath.section][indexPath.row])
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                push(AccountInfoVC())
            case 1:
                UIPasteboard.general.string = Login.currentAccount().email
                EToast.showSuccess("复制成功")
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                push(CompanyListVC())
            default:
                push(MemberListVC())
            }
        case 2:
            switch indexPath.row {
            case 0:
                let avatar = Login.currentAccount().avatarUrl.length > 0 ? Login.currentAccount().avatarUrl : "https://txc.qq.com/static/desktop/img/products/def-product-logo.png"
                let url = FeedbackUrl + "?nickname=\(Login.currentAccount().nickname)&avatar=\(avatar)&openid=coolbx_\(Login.currentAccount().userId)"
                pushToWebView(url)
            case 1:
                let email = "bd@kubaoxiao.com"
                if let url = URL(string: "mailto:\(email)") {
                    UIApplication.shared.open(url)
                }
                break
            case 2:
                push(AboutVC())
                break
            default:
                break
            }
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  20
    }
}
