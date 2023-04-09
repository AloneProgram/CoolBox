//
//  BXDetailInfoVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/8.
//

import UIKit
import WebKit

class BXDetailInfoVC: EViewController {
    
    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    //审批中、已通过 不显示底部view
    private var bottomActionView: BottomActionView!
    
    var bxInfo: BXInfoModel?
    
    private var eid = ""
    
    private var list: [[Any]] = []
    
    private var webView = WKWebView()
    
    private var importBtn = UIButton(type: .custom)
    
    init(eid: String) {
        self.eid = eid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDetail()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        leftTitle = "报销单详情"
        
        bottomViewHeight.constant = 48 + kBottomSpace
        
        if #available(iOS 15.0, *) {
            tableVIew.sectionHeaderTopPadding = 0
        }
        tableVIew.backgroundColor = .clear
       
        tableVIew.dataSource = self
        tableVIew.delegate = self
        let nib = UINib(nibName: "CommonInfoCell", bundle: nil)
        tableVIew.register(nib, forCellReuseIdentifier: "CommonInfoCell")
        tableVIew.estimatedRowHeight = 54
        tableVIew.separatorStyle = .none
        
        let infoNib = UINib(nibName: "CommonInfoCell", bundle: nil)
        tableVIew.register(infoNib, forCellReuseIdentifier: "CommonInfoCell")
        let fpNib = UINib(nibName: "BXFapiaoCell", bundle: nil)
        tableVIew.register(fpNib, forCellReuseIdentifier: "BXFapiaoCell")
        
        importBtn.isHidden = true
        importBtn.setTitle("导出", for: .normal)
        importBtn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        importBtn.titleLabel?.font = SCFont(16)
        importBtn.addTarget(self, action: #selector(importPDFAction), for: .touchUpInside)
        setRightBarButtonItems([UIBarButtonItem(customView: importBtn)])

        
    }

    
    //费用报销
    func feeBXInfoList() -> [[Any]] {
        return [
            [
                CommonInfoModel(leftText: "部门", rightText: bxInfo?.department ?? ""),
                CommonInfoModel(leftText: "日期", rightText: bxInfo?.date ?? ""),
                CommonInfoModel(leftText: "报销人", rightText: bxInfo?.username ?? ""),
                CommonInfoModel(leftText: "费用类型", rightText: GlobalConfigManager.getValue(with: bxInfo?.itemType ?? "0", in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceItemType)),
                CommonInfoModel(leftText: "报销事由", rightText: bxInfo?.reason ?? ""),
                CommonInfoModel(leftText: "报销总额", rightText: "¥" + (bxInfo?.totalFee ?? "")),
            ],
        ]
    }
    
    //差旅费报销
    func travelBXInfoList() -> [[Any]] {
        return [
            [
                CommonInfoModel(leftText: "部门", rightText: bxInfo?.department ?? ""),
                CommonInfoModel(leftText: "日期", rightText: bxInfo?.date ?? ""),
                CommonInfoModel(leftText: "报销人", rightText: bxInfo?.username ?? ""),
                CommonInfoModel(leftText: "报销事由", rightText: bxInfo?.reason ?? ""),
            ],
            [
                CommonInfoModel(leftText: "报销总额", rightText: "¥" + (bxInfo?.totalFee ?? "")),
                CommonInfoModel(leftText: "预借旅费", rightText: "¥" + (bxInfo?.preGetFee ?? "")),
                CommonInfoModel(leftText: "补领金额", rightText: "¥" + (bxInfo?.regetFee ?? "")),
                CommonInfoModel(leftText: "退还金额", rightText: "¥" + (bxInfo?.returnFee ?? "")),
            ],
            [CommonInfoModel(leftText: "完整信息", rightText: "查看", showRightArrow: true)],
        ]
    }
    
    func deleteBX() {
        guard let info = bxInfo else { return }
        BXApi.deleteBX(eid: info.id) {[weak self] _ in
            EToast.showSuccess("删除成功")
            self?.popViewController()
        }
    }
    
    func editBx() {
        guard let info = bxInfo else { return }
         removeCurrentAndPush(viewController: BXEditInfoVC(eId: info.id))
    }
    
    func sendSP() {
        //TODO: 发起审批
    }
    
    
    @objc func importPDFAction() {
        //TODO: 导出报销单
    }

    
    func addBottomView() {
        guard let info = bxInfo else { return }
        bottomView.isHidden = info.status == "1" || info.status == "3"
        bottomViewHeight.constant = bottomView.isHidden ? 0 : 48 + kBottomSpace
        if info.status == "0" || info.status == "5" {
            bottomActionView =  BottomActionView(type: .bx_detail, frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 48))
            bottomActionView.actionBlock = { [weak self] tag in
                switch tag {
                case 3:
                    self?.deleteBX()
                case 4:
                    self?.editBx()
                case 5:
                    self?.sendSP()
                default:
                    break
                }
            }
            bottomView.addSubview(bottomActionView)
        }
    }
    
    func defaulHeaderView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth * 200.0 / 375.0 + 36))
        let lab = UILabel(text: "报销单预览", font: SCFont(14), nColor: UIColor(hexString: "#939AA3"))
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(15)
        }
        
        let imageView = UIImageView(image: UIImage(named: "baoxiao_bg"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(36)
        }
        
        let icon = UIImageView(image: UIImage(named: "icon_baxiao"))
        view.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-17)
        }
        
        let tips = UILabel(text: "点击生成报销单", font: Font(16), nColor: UIColor(hexString: "#165DFF"))
        view.addSubview(tips)
        tips.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(icon.snp.bottom).offset(10)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(createFile))
        view.addGestureRecognizer(tap)
        return view
    }
    
    func pdfHeadView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 530 + 36))
        let lab = UILabel(text: "报销单预览", font: SCFont(14), nColor: UIColor(hexString: "#939AA3"))
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(15)
        }
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(36)
        }
        
        return view
    }
    
    
    @objc func createFile() {
        guard let info = bxInfo else { return }
        EHUD.show()
        BXApi.createPDFFile(eid: info.id) { [weak self] _ in
            
            EToast.showSuccess("生成成功")
            self?.getDetail()
        }
    }
}

//request
extension BXDetailInfoVC {
    func getDetail() {
        BXApi.getExpenseInfo(eid: eid) { [weak self]info in
            self?.bxInfo = info
            self?.list = info.type == "2" ? (self?.feeBXInfoList() ?? []) : (self?.travelBXInfoList() ?? [])
            
            if info.type == "2" {
                self?.list.append(info.invoiceData)
            }
            self?.tableVIew.reloadData()
            if let bView = self?.bottomActionView {
                bView.removeFromSuperview()
            }
            
            if info.pdfUrl.length > 0, let url = URL(string: info.pdfUrl) {
                self?.tableVIew.tableHeaderView = self?.pdfHeadView()
                self?.webView.load(URLRequest(url: url))
                self?.importBtn.isHidden = false
            }else {
                self?.tableVIew.tableHeaderView = self?.defaulHeaderView()
                self?.importBtn.isHidden = true
            }
            
            self?.addBottomView()
        }
    }

}

extension BXDetailInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if bxInfo?.type == "2", indexPath.section == 1 {
            let cell: BXFapiaoCell = tableView.dequeueReusableCell(withIdentifier: "BXFapiaoCell", for: indexPath) as! BXFapiaoCell
            cell.selectionStyle = .none
            cell.bindInvoice(list[1][indexPath.row] as! InvoiceData)
            return cell
        }
        let cell: CommonInfoCell = tableView.dequeueReusableCell(withIdentifier: "CommonInfoCell", for: indexPath) as! CommonInfoCell
        cell.selectionStyle = .none
        cell.bindData(list[indexPath.section][indexPath.row] as! CommonInfoModel)
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let info = bxInfo else { return }
        if indexPath.section == 2 {
            push(BXCompleteInfoVC(eId: info.id))
        } else if info.type == "2", indexPath.section == 1 {
            if let tmp = list[1][indexPath.row] as? InvoiceData, let fp = tmp.list.first {
                push(FPEditInfoVC(fp.id, hiddenBottom: true))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36))
            let lab = UILabel(text: "报销详情", font: SCFont(14), nColor: UIColor(hexString: "#939AA3"))
            view.addSubview(lab)
            lab.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(15)
            }
            
            let kindLab = UILabel(text: bxInfo?.type == "2" ? "费用报销" : "差旅费报销", font: SCFont(14), nColor: UIColor(hexString: "#939AA3"))
            view.addSubview(kindLab)
            kindLab.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(-15)
            }
            
            return view
        }else if bxInfo?.type == "2", section == 1 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 36))
            let lab = UILabel(text: "发票列表", font: SCFont(14), nColor: UIColor(hexString: "#939AA3"))
            view.addSubview(lab)
            lab.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(15)
            }
            return view
        }

        return section == 0 ? view : UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0 || (section == 1 && bxInfo?.type == "2")) ? 36 :  10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.01
    }
}
