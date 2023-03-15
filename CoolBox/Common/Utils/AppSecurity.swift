//
//  AppSecurity.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import Foundation

class AppSecurity: NSObject {
    // http://www.jianshu.com/p/96f8a8d0d9fc
    /// 正则匹配手机号
    static func checkTelNumber(_ telNumber: String) -> Bool {
        
        if telNumber.count > 11 {
            return false
        }
        
        let pattern = "^1+[356789]+\\d{9}"
        
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        
        let isMatch = pred.evaluate(with: telNumber)
        
        return isMatch
        
    }
    
    ////身份证校验
    static func checkIsIdentityCard(_ identityCard: String) -> Bool {
        //判断位数
        if identityCard.count != 15 && identityCard.count != 18 {
            return false
        }
        var carid = identityCard
        
        var lSumQT = 0
        
        //加权因子
        let R = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        
        //校验码
        let sChecker: [Int8] = [49, 48 ,88, 57, 56, 55, 54, 53, 52, 51, 50]
        
        //将15位身份证号转换成18位
        let mString = NSMutableString.init(string: identityCard)
        
        if identityCard.count == 15 {
            mString.insert("19", at: 6)
            var p = 0
            let pid = mString.utf8String
            for i in 0...16 {
                let t = Int(pid![i])
                p += (t - 48) * R[i]
            }
            let o = p % 11
            let stringContent = NSString(format: "%c", sChecker[o])
            mString.insert(stringContent as String, at: mString.length)
            carid = mString as String
        }
        
        let cStartIndex = carid.startIndex
//        let cEndIndex = carid.endIndex
        let index = carid.index(cStartIndex, offsetBy: 2)
        //判断地区码
        let sProvince = String(carid[cStartIndex..<index])
        if (!self.areaCodeAt(sProvince)) {
            return false
        }
        
        //判断年月日是否有效
        //年份
        let yStartIndex = carid.index(cStartIndex, offsetBy: 6)
        let yEndIndex = carid.index(yStartIndex, offsetBy: 4)
        guard let year = Int(carid[yStartIndex..<yEndIndex]) else { return false }
        let strYear = String(format: "%02d", year)
        
        //月份
        let mStartIndex = carid.index(yEndIndex, offsetBy: 0)
        let mEndIndex = carid.index(mStartIndex, offsetBy: 2)
        guard let month = Int(carid[mStartIndex..<mEndIndex]) else { return false }
        let strMonth = String(format: "%02d", month)
        
        //日
        let dStartIndex = carid.index(mEndIndex, offsetBy: 0)
        let dEndIndex = carid.index(dStartIndex, offsetBy: 2)
        guard let day = Int(carid[dStartIndex..<dEndIndex]) else { return false }
        let strDay = String(format: "%02d", day)
        
        let localZone = NSTimeZone.local
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = localZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let format = "\(strYear)-\(strMonth)-\(strDay) 12:01:01"
        guard let _ = dateFormatter.date(from: format) else { return false }
        
        let paperId = carid.utf8CString
        //检验长度
        if 18 != carid.count {
            return false
        }
        //校验数字
        func isDigit(c: Int) -> Bool {
            return 0 <= c && c <= 9
        }
        for i in 0...18 {
            let id = Int(paperId[i])
            if isDigit(c: id) && !(88 == id || 120 == id) && 17 == i {
                return false
            }
        }
        //验证最末的校验码
        for i in 0...16 {
            let v = Int(paperId[i])
            lSumQT += (v - 48) * R[i]
        }
        if sChecker[lSumQT%11] != paperId[17] {
            return false
        }
        return true

    }
    
   private static func areaCodeAt(_ code: String) -> Bool {
        var dic: [String: String] = [:]
        dic["11"] = "北京"
        dic["12"] = "天津"
        dic["13"] = "河北"
        dic["14"] = "山西"
        dic["15"] = "内蒙古"
        dic["21"] = "辽宁"
        dic["22"] = "吉林"
        dic["23"] = "黑龙江"
        dic["31"] = "上海"
        dic["32"] = "江苏"
        dic["33"] = "浙江"
        dic["34"] = "安徽"
        dic["35"] = "福建"
        dic["36"] = "江西"
        dic["37"] = "山东"
        dic["41"] = "河南"
        dic["42"] = "湖北"
        dic["43"] = "湖南"
        dic["44"] = "广东"
        dic["45"] = "广西"
        dic["46"] = "海南"
        dic["50"] = "重庆"
        dic["51"] = "四川"
        dic["52"] = "贵州"
        dic["53"] = "云南"
        dic["54"] = "西藏"
        dic["61"] = "陕西"
        dic["62"] = "甘肃"
        dic["63"] = "青海"
        dic["64"] = "宁夏"
        dic["65"] = "新疆"
        dic["71"] = "台湾"
        dic["81"] = "香港"
        dic["82"] = "澳门"
        dic["91"] = "国外"
        if (dic[code] == nil) {
            return false;
        }
        return true;
    }
    
    //  正则数字,1-8位的数字 range 最多几位数字，最少几位数字
    static func checkNumber(_ number: String, _ min: Int, _ max: Int) -> Bool {
        let pattern = "^[0-9]{\(min),\(max)}"
        
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        
        let isMatch = pred.evaluate(with: number)
        
        return isMatch
        
    }
    
    // 正则匹配用户密码6-12位数字和字母组合
    static func checkPassword(password: String) -> Bool {
        let res: Bool = password.count >= 6 && password.count <= 18
        if res {
            let pattern = "^[0-9A-Za-z]{6,20}$" // 字母或数字
            
            let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
            
            let isMatch = pred.evaluate(with: password)
            
            return isMatch
            
        }
        return false
    }
    
    /**
     * 字母、数字、中文正则判断（不包括空格）
     */
    static func isInputRuleNotBlank(str: String) -> Bool {
        let pattern = "^[\\u4e00-\\u9fa5a-zA-Z-z0-9]+$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        
        let isMatch = pred.evaluate(with: str)
        
        return isMatch
    }
}
