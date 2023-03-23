//
//  CompanyListVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit

class CompanyListVC: EViewController, PresentToCenter {
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    var bottomContentView = BaseHeightBottomView.instance()
    
    var companyList: [CompanyModel] = []
    
    private var footerView: UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36))
        let lab = UILabel(text: "请使用电脑浏览器登录 kubaoxiao.com 管理组织架构", font: Font(12), nColor: UIColor(hexString: "#86909C"))
        footerView.backgroundColor = .clear
        footerView.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
        }
        return footerView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCompanylist()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = EColor.viewBgColor
        tableview.backgroundColor = .clear
        
        leftTitle = "组织列表"
        bottomViewHeight.constant = 76 + kBottomSpace
        
        if #available(iOS 15.0, *) {
            tableview.sectionHeaderTopPadding = 0
        }
        tableview.dataSource = self
        tableview.delegate = self
        let nib = UINib(nibName: "CommonInfoCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: "CommonInfoCell")
        tableview.estimatedRowHeight = 54
        tableview.separatorStyle = .none
        
        bottomContentView.bottomType = .companyList
        bottomContentView.leftBlock = { [weak self] in
            self?.clickJoinCompany()
        }
        bottomContentView.rightBlock = { [weak self] in
            self?.push(CreateVC(.createCompany))
        }
        bottomView.addSubview(bottomContentView)
        bottomContentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(76)
        }
        
        view.addSubview(footerView)
        footerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(36)
            make.bottom.equalTo(bottomView.snp.top)
        }
        bottomContentView.bottomType = .joinCompany
    }
    
    func getCompanylist() {
        MineApi.getCompanyList { [weak self] listModel in
            if let listModel = listModel {
                self?.companyList = listModel.list
                self?.tableview.cyl_reloadData()
                self?.footerView.isHidden = listModel.list.count == 0
                self?.bottomContentView.bottomType = listModel.list.count == 0 ? .companyList : .joinCompany
            }
        }
    }
    
    func clickJoinCompany() {
        let alert = CompanyInviteAlert(title: "组织邀请码", content: "需通过邀请链接，获取组织邀请码", placeText: "", confirm:  { [weak self] code in
            self?.joinCompany(code)
        })
        
        presentToCenter(alert)
    }
    
    func joinCompany(_ code: String) {
        MineApi.joinCompany(code: code) { [weak self]success in
            if success {
                self?.getCompanylist()
            }
        }
    }
}

extension CompanyListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CommonInfoCell = tableView.dequeueReusableCell(withIdentifier: "CommonInfoCell", for: indexPath) as! CommonInfoCell
        cell.selectionStyle = .none
        cell.bindCompay(companyList[indexPath.row])
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let c = companyList[indexPath.row]
        MineApi.setDefaultCompany(cid: c.companyId) { [weak self]_ in
            self?.getCompanylist()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36))
        let lab = UILabel(text: "全部组织", font: Font(14), nColor: UIColor(hexString: "#939AA3"))
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.01
    }
}

extension CompanyListVC: CYLTableViewPlaceHolderDelegate {
    func makePlaceHolderView() -> UIView! {
        return UIView.blankMsgView("你可以创建一个组织，或者加入一个组织", imageStr: "")
    }
}
