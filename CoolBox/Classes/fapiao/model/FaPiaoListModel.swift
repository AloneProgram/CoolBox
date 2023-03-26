//
//  FaPiaoListModel.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/25.
//

import UIKit

struct FaPiaoListModel {
    var list: [FaPiaoModel] = []
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        list = json.arrayValue.map({FaPiaoModel(fromJson: $0)})
    }
}

struct FaPiaoModel {

    var buyerAddressAndPhone = ""
    var buyerBankAccount = ""
    var buyerName = ""
    var buyerTaxCode = ""
    var catId = ""
    var checkCode = ""
    var code = ""
    var detail = ""
    var expenseId = ""
    var fee = ""
    var feeWithoutTax = ""
    var fileUrl = ""
    var id = ""
    var isDataComplete = ""
    var isSync = ""
    var isVerifyTruth = ""
    var itemType = ""
    var num = ""
    var productionDate = ""
    var sellerAddressAndPhone = ""
    var sellerBankAccount = ""
    var sellerName = ""
    var sellerTaxCode = ""
    var sourceType = ""
    var status = ""
    var subject = ""
    var tax = ""
    var time = ""
    var title = ""
    var type = ""
    var userId = ""
    var invalidTitle = ""


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        buyerAddressAndPhone = json["buyer_address_and_phone"].stringValue
        buyerBankAccount = json["buyer_bank_account"].stringValue
        buyerName = json["buyer_name"].stringValue
        buyerTaxCode = json["buyer_tax_code"].stringValue
        catId = json["cat_id"].stringValue
        checkCode = json["check_code"].stringValue
        code = json["code"].stringValue
        detail = json["detail"].stringValue
        expenseId = json["expense_id"].stringValue
        fee = json["fee"].stringValue
        feeWithoutTax = json["fee_without_tax"].stringValue
        fileUrl = json["file_url"].stringValue
        id = json["id"].stringValue
        isDataComplete = json["is_data_complete"].stringValue
        isSync = json["is_sync"].stringValue
        isVerifyTruth = json["is_verify_truth"].stringValue
        itemType = json["item_type"].stringValue
        num = json["num"].stringValue
        productionDate = json["production_date"].stringValue
        sellerAddressAndPhone = json["seller_address_and_phone"].stringValue
        sellerBankAccount = json["seller_bank_account"].stringValue
        sellerName = json["seller_name"].stringValue
        sellerTaxCode = json["seller_tax_code"].stringValue
        sourceType = json["source_type"].stringValue
        status = json["status"].stringValue
        subject = json["subject"].stringValue
        tax = json["tax"].stringValue
        time = json["time"].stringValue
        title = json["title"].stringValue
        type = json["type"].stringValue
        userId = json["user_id"].stringValue
        
        if json["invalid_title"].stringValue.length > 0 {
            self.invalidTitle = json["invalid_title"].stringValue
        }else if isSync == "0" {
            invalidTitle = "发票信息正在同步"
        }else if isSync == "2" {
            invalidTitle = "发票信息同获取失败"
        }else if isDataComplete == "0" {
            self.invalidTitle = "该发票信息不完整，请手动修改"
        }
    }

}
