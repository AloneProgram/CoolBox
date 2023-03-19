//
//  AboutVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/19.
//

import UIKit
import Alamofire

class AboutVC: EViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    private var list: [[CommonInfoModel]] = [
        [
            CommonInfoModel(leftText: "用户协议", showRightArrow: true),
            CommonInfoModel( leftText: "隐私政策", showRightArrow: true)
        ],
        [
            CommonInfoModel(leftText: "检查更新", showRightArrow: true)
        ],
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftTitle = "关于酷报销"
        
        let infoDictionary = Bundle.main.infoDictionary
        if let version :String = infoDictionary!["CFBundleShortVersionString"] as? String  {
            versionLabel.text = "v\(version)"
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "CommonInfoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommonInfoCell")
        tableView.estimatedRowHeight = 54
        tableView.separatorStyle = .none
    }


}

extension AboutVC: UITableViewDelegate, UITableViewDataSource {
    
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
                pushToWebView(UserAreegemnt)
            case 1:
                pushToWebView(PrivacyPlice)
            default:
                break
            }
        case 1:
            VersionCheckManager.checkVersion(appId: "1660515353") { equal in
                DispatchQueue.main.async {
                    if !equal {
                        let str = "itms-apps://itunes.apple.com/app/id1660515353"
                        guard let url = URL(string: str) else { return }
                        UIApplication.shared.open(url)
                    }else {
                        EToast.showInfo("当前为最新版本")
                    }
                }
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


class VersionCheckManager: NSObject {

    // MARK: - check to see if you need to update the version
    // - Parameter appId: application appId
    // - Returns: true : The current version is lower than the store version
    // - false : The current version is equal to or higher than the store version
    static func checkVersion(appId:String,compareResult: @escaping (Bool) -> Void) {

        VersionCheckManager.appSoreVersion(appId: appId) { (appVersion) -> Void in
            let localVersion : String = VersionCheckManager.currentVersion()
            compareResult(localVersion == appVersion)
        }
    }


    static func appSoreVersion(appId:String, handle: @escaping ((String) -> Void)) {
        let urlString = "http://itunes.apple.com/lookup?id=\(appId)"
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        session.dataTask(with: urlRequest) {  (data, _, error) in
            if let data = data, error == nil {
                do {
                    if let appMsgDict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        let appResultsArray:NSArray = (appMsgDict["results"] as? NSArray)!
                        let appResultsDict:NSDictionary = appResultsArray.lastObject as? NSDictionary ?? ["":""]
                        guard let appStoreVersion = appResultsDict["version"] as? String else {
                            return
                        }
                        handle(appStoreVersion)
                    }
                }
                catch { print(error)  }
            }
        }.resume()
        
    }

    // MARK: - Get the current version well
    // - Returns: current version
    static func currentVersion() -> String {

        guard let localVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return localVersion
    }
}
