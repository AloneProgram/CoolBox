//
//  AppContansts.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import Foundation
import SnapKit

// MARK: - 服务器请求的 BaseURL
#if RELEASE  //生产环境
    let AppAPIBaseURLString = "https://s-rc-shopmate.ehuandian.net"
#else
    let ApiBaseURLKey = "APIBaseURL"
    func getBaseUrl() -> String {
        if let baseUrl = UserDefaults.standard.value(forKeyPath: "APIBaseURL") as? String {
            return baseUrl
        }
        else {
            return "http://t-rc-shopmate.ehuandian.net"
        }
    }
    let AppAPIBaseURLString = getBaseUrl()
#endif



#if DEBUG
    let kOnline = false
#elseif DEVELOP 
    let kOnline = false
#else
    let kOnline = true
#endif

func print(_ item: @autoclosure () -> Any) {
    #if DEBUG
    Swift.print(item())
    #endif
}

func ELog<N>(message: N, fileName: NSString = #file, methodName: String = #function, lineNumber:Int = #line) {
    print("----------------------------------------")
    print("data:    \(Date())")
    print("file:    \(fileName.lastPathComponent)")
    print("method:  \(methodName)")
    print("line:    \(lineNumber)")
    print("message: \(message)")
    print("----------------------------------------")
}

/** 分页数据，默认分页大小 */
let kPageSize: Int = 18

// 屏幕宽高
let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

// 相对iphone6的屏占比系数
let kWidthScale = kScreenWidth/375.0
let kHeightScale = kScreenHeight/667.0

// 刘海屏系列
let iPhoneXs = Int(100 * kScreenHeight / kScreenWidth) == 216

// 状态栏高度
let kStatusBarHeight : CGFloat = iPhoneXs ? 44 : 20

// 导航栏高度
let kNaviBarHeight : CGFloat = (kStatusBarHeight + 44)

//底部button距离
let kBottomSpace : CGFloat = iPhoneXs ? 34 : 0

// tabbar高度
let kTabBarHeight: CGFloat = (kBottomSpace + 49)

//协议
///---注册
func userSerUrl() -> String{
    return "https://h5-vue.ehuandian.net/rentalScooter/huandian/dist/index.html#/Agreement"
}
//隐私政策
func policyUrl()-> String {
    return "https://h5-vue.ehuandian.net/rentalScooter/huandian/dist/index.html#/policy"
}
///----FAQ_merchant
func faqMerchant() -> String {
    return "https://h5-vue.ehuandian.net/rentalScooter/huandian/dist/index.html#/agentCmProblem"
}
///----FAQ_user
func faqUser() -> String {
    return "https://h5-vue.ehuandian.net/rentalScooter/huandian/dist/index.html#/userCmProblem"
}
///--cardInfo
func carInfo() -> String {
    return "https://h5-vue.ehuandian.net/rentalScooter/huandian/dist/index.html#/"
}


//-----分享小程序path----
///门店详情页
func sotrePath(storeId: String) -> String {
    return "/pages/package-discover/shop-detail/main?storeId=\(storeId)&isShareFromMessage=1"
}
///商品详情页
func goodsPath(goodsId: String) -> String {
    let shareUuid = shareUUid(id: goodsId)
    BrowseApi.sharePost(.goods, id: goodsId)
    return "/pages/commodity-show/main?goodsId=\(goodsId)&uuid=\(shareUuid)"
}

///服务详情页
func servicesPath(serviceId: String) -> String {
    let shareUuid = shareUUid(id: serviceId)
    BrowseApi.sharePost(.services, id: serviceId)
    return "pages/package-common/service-details/main?businessId=\(serviceId)&uuid=\(shareUuid)"
}

///内容详情页
func contentPath(contentId: String) -> String {
    let shareUuid = shareUUid(id: contentId)
    BrowseApi.sharePost(.content, id: contentId)
    return "/pages/package-discover/content-detail/main?id=\(contentId)&uuid=\(shareUuid)"
}
///视频
func videoPath(videoId: String) -> String {
    let shareUuid = shareUUid(id: videoId)
    BrowseApi.sharePost(.content, id: videoId)
    return "/packages/video/video-detail/video-detail?videoId=\(videoId)&uuid=\(shareUuid)"
}

//短视频
func shortVideoPath(videoId: String) -> String {
    let shareUuid = shareUUid(id: videoId)
    BrowseApi.sharePost(.content, id: videoId)
    return "/pages/package-common/video/main?clickVideoId=\(videoId)&uuid=\(shareUuid)"
}

//个人中心
func personalPath(userId: String, role: Int) -> String {
    let shareUuid = shareUUid(id: userId)
    BrowseApi.sharePost(.user, id: userId)
    return "/pages/package-mine/user-center/main?id=\(userId)&uuid=\(shareUuid)&role=\(role)"
}


func shareUUid(id: String) -> String {
    guard let phone = Login.currentAccount().userPhone else { return ""  }
    return "\((id))_\(phone)_\(ENetworking.timestamp())"
}

//获取视频首帧画面图片
func videoToImg(videoUrl: String) -> String {
    return videoUrl + "?x-oss-process=video/snapshot,t_1000,m_fast,ar_auto"
}

