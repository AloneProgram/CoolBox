//
//  SPDetailVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/9.
//

import UIKit

class SPDetailVC: EViewController, PresentFromBottom, PresentToCenter {

    
    @IBOutlet weak var paddingLabel: PaddingLabel!
    
    @IBOutlet weak var paddingWid: NSLayoutConstraint!
    @IBOutlet weak var bxTitleLabel: UILabel!
    
    @IBOutlet weak var bxInfoLabel: UILabel!
    
    @IBOutlet weak var feeLabel: UILabel!
    
    @IBOutlet weak var toBxInfoView: UIView!
    
    @IBOutlet weak var toBxInfoViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var changeProcessBtn: UIButton!
    
    @IBOutlet weak var statusLabel: PaddingLabel!
    
    @IBOutlet weak var statusWid: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tipsLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomViewHeioght: NSLayoutConstraint!
    
    var commitView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 48))
        let btn = UIButton(title: "提交", bgColor: UIColor(hexString: "#165DFF"))
        btn.addTarget(self, action: #selector(commitAction), for: .touchUpInside)
        btn.cornerRadius = 2
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalTo(16)
            make.top.equalTo(8)
        }
        return view
    }()
    
    //报销单ID--  创建审批单
    var eid = ""
    
    //审批单id   --审批单详情
    var exId = ""
        
    var processList: [ProcessModel] = []
    var bxInfo: BXInfoModel?
    
    private var bottomActionView: BottomActionView!
    
    init(eId: String = "", exId: String = "" ) {
        self.eid = eId
        self.exId = exId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftTitle = eid.length > 0 ? "发起审批" : "审批详情"
        bottomViewHeioght.constant = 48 + kBottomSpace
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.contentInset = UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "SPProcessCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SPProcessCell")
        tableView.estimatedRowHeight = 64
        tableView.separatorStyle = .none
        
        toBxInfoView.isHidden = eid.length > 0
        toBxInfoViewHeight.constant = toBxInfoView.isHidden ? 0 : 54
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toBxInfoPage))
        toBxInfoView.addGestureRecognizer(tap)
        
        if eid.length > 0 {
            getExpeneInfo(eId: eid)
            getProcessList()
            bottomView.addSubview(commitView)
        }else {
            getSPInfo()
        }
        
        statusLabel.isHidden = eid.length > 0
        changeProcessBtn.isHidden = !statusLabel.isHidden
        
        tipsLabel.text = eid.length > 0 ? "请使用电脑浏览器登录 kubaoxiao.com查看电子发票" : "发票验真、查重、连号检测已完成\n请使用电脑浏览器登录 kubaoxiao.com查看"
    }
    
    
    func updateInfoView(info: BXInfoModel) {
        bxInfo = info
        
        paddingLabel.text = info.type == "1" ? "差旅费报销" : "费用报销"
        paddingWid.constant = paddingLabel.text!.widthWithConstrainedHeight(height: 20, font: Font(12)) + 8
        paddingLabel.style = .blue
        bxTitleLabel.text = info.reason
        feeLabel.text = "¥\(info.totalFee)"
        
        bxInfoLabel.text = "部门:\(info.department)\n出差人:\(info.username)\n报销日期:\(info.date)"
        
        //报销状态 0未审批 1审核中 3已报销 5审核驳回
        switch Int(info.status) {
        case  0 :
            statusLabel.text = "未审核"
            statusWid.constant = 44
            statusLabel.style = .gray
        case  1 :
            statusLabel.text = "审批中"
            statusWid.constant = 44
            statusLabel.style = .blue
        case  3 :
            statusLabel.text = "已通过"
            statusWid.constant = 44
            statusLabel.style = .green
        case  5 :
            statusLabel.text = "已拒绝"
            statusWid.constant = 44
            statusLabel.style = .red
        default:
            statusWid.constant = 0
            break
            
        }
    }
  
    
    func updateBottomActionView() {
        guard let info = bxInfo else { return }
        bottomView.isHidden = false
        bottomView.subviews.forEach({$0.removeFromSuperview()})
        
        var btootomActionType: BottomActionType = .sp_first
        
        let cureentSPUser = processList.first(where: {$0.status.rawValue == "1"})
        
        //是否是我审批
        let isMySp = (cureentSPUser?.userId ?? "") == Login.currentAccount().userId
        
        //是否是我发起
        let isMySend = info.userId == Login.currentAccount().userId
 
        
        if isMySend, !isMySp {
            btootomActionType = .sp_first
        }else if isMySend, isMySp {
            btootomActionType = .sp_second
        }else if !isMySend, isMySp {
            btootomActionType = .sp_second
        }else if isMySp {
            if info.status == "3" {
                btootomActionType = .sp_fourth
            }else if info.status == "5" {
                btootomActionType = .sp_fifth
            }
        }else if isMySend {
            if info.status == "3" {
                btootomActionType = .sp_seventh
            }else if info.status == "5" {
                btootomActionType = .sp_sixth
            }
        }
        
        if info.status == "3" {
            if isMySp {
                btootomActionType = .sp_fourth
            }
            if isMySend {
                btootomActionType = .sp_seventh
            }
        }
        
        if info.status == "5", isMySend {
            if isMySp {
                btootomActionType = .sp_fifth
            }
            if isMySend {
                btootomActionType = .sp_sixth
            }
        }
        
        if btootomActionType != .sp_seventh {
            bottomView.isHidden = false
            bottomActionView =  BottomActionView(type: btootomActionType, frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 48))
            bottomActionView.actionBlock = { [weak self] tag in
                switch tag {
                case 6:
                    self?.revocationSP()
                case 7:
                    self?.refuseSP()
                case 8:
                    self?.passSP()
                case 9:
                    break
                case 10:
                    break
                case 11:
                    self?.resendSp()
                default:
                    break
                }
            }
            bottomView.addSubview(bottomActionView)
        }else {
            bottomView.isHidden = true
        }
                

    }
    
    @IBAction func tpChangeProcessPage(_ sender: Any) {
        let vc = SetProcessListVC()
        vc.commitBlock = { [weak self] in
            self?.getProcessList()
        }
        push(vc)
    }
    
}

//action
extension SPDetailVC {
    @objc func commitAction() {
        createSP()
    }

    @objc func toBxInfoPage(){
        guard let info = bxInfo else {
            return
        }
        push(BXDetailInfoVC(eid: info.eid))
    }

    func addUser(row: Int) {
        let vc = MemberListVC(isMemberList: false)
        vc.selectUserBlock = {[weak self] item in
            self?.processList[row].name = item.title
            self?.processList[row].userId = item.userId
            self?.processList[row].memberId = item.id
            self?.tableView.reloadData()
        }
        push(vc)
    }

    func changeUser(row: Int) {
        let vc = MemberListVC(isMemberList: false)
        vc.selectUserBlock = {[weak self] item in
            self?.processList[row].name = item.title
            self?.processList[row].userId = item.userId
            self?.processList[row].memberId = item.id
            self?.tableView.reloadData()
        }
        push(vc)
    }

    func inviteUse(row: Int) {
        guard  let cureentSPUser = processList.first(where: {$0.status.rawValue == "1"}) else { return}
        var content = ShareContent()
        content.title = "[有人@我]这张报销单正在等你审批"
        content.shareUrl = cureentSPUser.invitationUrl
        content.description = "点击进入，一键审批"
        content.viewController = self
        content.completed = {type in
            EToast.showSuccess("分享成功")
        }
        ShareTool.do(content, config: ShareUIConfig(title: "分享到", cornerRadius: 18), at: self)
    }
    
    //撤回审批
    func revocationSP() {
        let alert = CustomAlert(title: "系统提示", content: "是否确认撤回本次审批申请", confirmTitle: "确定", confirm:  { [weak self] in
            self?.deleteSp()
        })
        presentToCenter(alert)
    }
    
    //通过审批
    func passSP() {
        handleSPD(refuse: false)
    }
    
    //拒绝审批
    func refuseSP() {
        let handler: ((String) -> Void) = {[weak self] text in
            self?.handleSPD(refuse: true, reson: text)
        }
        let alert = SP_RefuseReasonAlert(handle: handler)
        presentFromBottom(alert)
    }
    
    // 再次提交
    func resendSp() {
        guard let info = bxInfo else {return}
        removeCurrentAndPush(viewController: BXDetailInfoVC(eid: info.eid))
    }
    
}

//requset
extension SPDetailVC {
    func getExpeneInfo(eId: String){
        BXApi.getExpenseInfo(eid: eId) { [weak self] info in
            self?.updateInfoView(info: info)
        }
    }
    
    func getProcessList() {
        SPApi.getProcessList {[weak self] list in
            self?.processList = list.list
            self?.processList.enumerated().forEach({ idx, obj in
                var tmp = obj
                if idx < (self?.processList.count ?? 0) - 2, let s = self?.processList[idx + 1].status {
                    tmp.nextStatus = s
                }
                self?.processList[idx] = tmp
            })
            self?.tableView.reloadData()
        }
    }
    
    func getSPInfo() {
        SPApi.getSPInfo(exId: exId) { [weak self] detail in
            if let info = detail.bxInfo {
                self?.updateInfoView(info: info)
            }
            if let list = detail.processList {
                self?.processList = list.list
                self?.processList.enumerated().forEach({ idx, obj in
                    var tmp = obj
                    if idx < (self?.processList.count ?? 0) - 2, let s = self?.processList[idx + 1].status {
                        tmp.nextStatus = s
                    }
                    self?.processList[idx] = tmp
                })
                self?.tableView.reloadData()
            }
            
            self?.updateBottomActionView()
        }
    }
    
    
    func createSP() {
        var processDicArr: [[String: Any]] = []
        processList.forEach { model in
            var params: [String: String] = [:]
            params["member_id"] = model.memberId
            params["name"] = model.name
            params["node_name"] = model.nodeName
            processDicArr.append(params)
        }
        guard var dataStr = JSON(processDicArr).rawString() else { return}
        dataStr = dataStr.replacingOccurrences(of: "\n", with: "")
        dataStr = dataStr.replacingOccurrences(of: " ", with: "")
        SPApi.createSP(cid: Login.currentAccount().companyId, eid: eid, processStr: dataStr) { [weak self]exId in
            self?.removeCurrentAndPush(viewController: SPDetailVC(exId: exId))
        }
    }
    
    func deleteSp() {
        SPApi.deleteSP(exid: exId) {[weak self] success in
            self?.popViewController()
        }
    }
    
    func handleSPD(refuse: Bool, reson: String = "") {
        SPApi.handleSPD(id: exId, status: refuse ? 5 : 3, reson: reson) {[weak self] success in
            if success {
                self?.getSPInfo()
            }
        }
    }
}

extension SPDetailVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return processList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SPProcessCell = tableView.dequeueReusableCell(withIdentifier: "SPProcessCell", for: indexPath) as! SPProcessCell
        cell.selectionStyle = .none
        cell.bindData(process: processList[indexPath.row], isCrerateSP: eid.length > 0, isLastLine: indexPath.row == processList.count - 1, isFirst: indexPath.row == 0 )
        cell.clickAddUser = { [weak self] in
            self?.addUser(row: indexPath.row)
        }
        cell.clickChangeUser = {[weak self] in
            self?.changeUser(row: indexPath.row)
        }
        cell.clickInviteUser = {[weak self] in
            self?.inviteUse(row: indexPath.row)
        }
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
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

        return 0.01
    }
  
}
