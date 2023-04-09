//
//  ProcessModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/9.
//

import UIKit

enum SPStatus: String {
    //未审批
    case unSp = "0"
    //审批中
    case sping = "1"
    //已审批
    case sped = "3"
    //已拒绝
    case refused = "5"
    
    var statusStr: String {
        switch self {
        case .sped:
            return "已通过"
        case .refused:
            return "已拒绝"
        default:
            return ""
        }
    }
    
    var lineColor: UIColor {
        switch self {
        case .unSp:
            return UIColor(hexString: "#E5E6EB")
        case .sping:
            return UIColor(hexString: "#165DFF")
        case .sped:
            return UIColor(hexString: "#165DFF")
        case .refused:
            return UIColor(hexString: "#FF5722")
        }
    }
    
    var statusTextColor: UIColor? {
        switch self {
        case .sped:
            return UIColor(hexString: "#00B42A")
        case .refused:
            return UIColor(hexString: "#F53F3F")
        default: return nil
        }
    }
}

struct ProcessList {
    var list: [ProcessModel] = []
    init(_ json: JSON) {
       
        let tmpArr = json["process_list"].arrayValue
        
        if tmpArr.count > 0 {
            list = tmpArr.map({ProcessModel(fromJson: $0)})
        }else {
            list = json.arrayValue.map({ProcessModel(fromJson: $0)})
        }
       
    }
}

struct ProcessModel {

    var invitation : String!
    //1: 是自己,
    var isUser : String!
    //审批人
    var memberId : String!
    var memberStatus : String!
    var name : String!
    var nodeName : String!
    var reason : String!
    ///审批状态0未审批 1审核中 3已审核 5审核驳回
    var status: SPStatus = .unSp
    var time : String!
    //发起人
    var userId : String!
    var invitationUrl: String!
    
    //自定义参数:
        //下一级状态
    var nextStatus: SPStatus = .unSp


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        invitation = json["invitation"].stringValue
        isUser = json["is_user"].stringValue
        memberId = json["member_id"].stringValue
        memberStatus = json["member_status"].stringValue
        name = json["name"].stringValue
        nodeName = json["node_name"].stringValue
        reason = json["reason"].stringValue
        if let s = SPStatus(rawValue: json["status"].stringValue) {
            status = s
        }
        time = json["time"].stringValue
        userId = json["user_id"].stringValue
        invitationUrl = json["invitation_url"].stringValue
    }

    func toDictionary() -> [String:Any]
        {
            var dictionary = [String:Any]()
            if invitation != nil{
                dictionary["invitation"] = invitation
            }
            if invitationUrl != nil{
                dictionary["invitation_url"] = invitationUrl
            }
            if isUser != nil{
                dictionary["is_user"] = isUser
            }
            if memberId != nil{
                dictionary["member_id"] = memberId
            }
            if memberStatus != nil{
                dictionary["member_status"] = memberStatus
            }
            if name != nil{
                dictionary["name"] = name
            }
            if nodeName != nil{
                dictionary["node_name"] = nodeName
            }
            if reason != nil{
                dictionary["reason"] = reason
            }
            dictionary["status"] = status.rawValue
            if time != nil{
                dictionary["time"] = time
            }
            if userId != nil{
                dictionary["user_id"] = userId
            }
            return dictionary
        }
    

}



struct ProcessNode {
    var cId : String!
    var examineProcess : [Process] = []

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        cId = json["c_id"].stringValue
        examineProcess = [Process]()
        let examineProcessArray = json["examine_process"].arrayValue
        for examineProcessJson in examineProcessArray{
            let value = Process(fromJson: examineProcessJson)
            examineProcess.append(value)
        }
    }
}

struct Process {
    var nodeName : String!
    
    //自定义参数
    //是否处于添加节点状态
    var isAdd = false
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        nodeName = json["node_name"].stringValue
    }
    
    init(nodeName: String) {
        self.nodeName = nodeName
    }
}
