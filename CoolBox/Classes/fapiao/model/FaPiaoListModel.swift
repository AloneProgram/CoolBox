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


struct CameraImportFaPiaoList {
    var list: [FaPiaoModel] = []
    var invalidList: [FaPiaoModel] = []
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        list = json["data"].arrayValue.map({FaPiaoModel(fromJson: $0)})
        invalidList = json["invalid_data"].arrayValue.map({FaPiaoModel(fromJson: $0)})
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
    ///临时发票id
    var invoiceId = ""


    //自定义参数
    var isSelected = false
    var isSelectListPage = false
    
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
        invoiceId = json["invoice_id"].stringValue
        
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


struct FapiaoDetailModel {
    var buyerName = ""
    var catId = ""
    var checkCode = ""
    var code = ""
    var data : FapiaoData!
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
    var sellerName = ""
    var status = ""
    var subject = ""
    var tax = ""
    var template : [Template]!
    var time = ""
    var title = ""
    var type = ""
    var userId = ""
    var remark = ""


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        buyerName = json["buyer_name"].stringValue
        catId = json["cat_id"].stringValue
        checkCode = json["check_code"].stringValue
        code = json["code"].stringValue
        let dataJson = json["data"]
        if !dataJson.isEmpty{
            data = FapiaoData(fromJson: dataJson)
        }
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
        sellerName = json["seller_name"].stringValue
        status = json["status"].stringValue
        subject = json["subject"].stringValue
        tax = json["tax"].stringValue
        template = [Template]()
        let templateArray = json["template"].arrayValue
        for templateJson in templateArray{
            let value = Template(fromJson: templateJson, detailJson: json)
            template.append(value)
        }
        remark = json["data"]["remark"].stringValue
        
        time = json["time"].stringValue
        title = json["title"].stringValue
        type = json["type"].stringValue
        userId = json["user_id"].stringValue
    }

}

struct Template {
    var edit = ""
    var field = ""
    var name = ""
    // 1: 必填参数
    var required = ""
    //show : 1 在详情页显示
    var show = ""
    var type = ""
    
    //自定义参数
    var value = ""


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!, detailJson: JSON){
        if json.isEmpty{
            return
        }
        edit = json["edit"].stringValue
        field = json["field"].stringValue
        name = json["name"].stringValue
        required = json["required"].stringValue
        show = json["show"].stringValue
        type = json["type"].stringValue
        
        if field == "item_type" { //消费类型
            value = GlobalConfigManager.getValue(with: detailJson[field].stringValue, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceItemType)
        }else if field == "type" { //发票类型
            value = GlobalConfigManager.getValue(with: field, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceType)
        }else if field == "cat_id" { 
            value = GlobalConfigManager.getValue(with: field, in: GlobalConfigManager.shared.systemoInfoConfig?.invoidceCatId)
        }else if field == "remark" {
            value = detailJson["data"]["remark"].stringValue
        }
        else {
            if type == "datetime" {
                value = detailJson[field].stringValue
            }else {
                value = detailJson["data"][field].stringValue
            }
            
        }
        
    }

}


struct FapiaoData {
    var buyerAddressAndPhone = ""
    var buyerBankAccount = ""
    var buyerName = ""
    var buyerTaxCode = ""
    var catId = ""
    var checkCode = ""
    var code = ""
    var detail = ""
    var fee = ""
    var feeWithoutTax = ""
    var fileUrl = ""
    var isDataComplete = ""
    var isTruth = ""
    var itemType = ""
    var num = ""
    var productionDate = ""
    var remark = ""
    var sellerAddressAndPhone = ""
    var sellerBankAccount = ""
    var sellerName = ""
    var sellerTaxCode = ""
    var sourceType = ""
    var tax = ""
    var time = ""
    var title = ""
    var type = ""
    var userId = ""


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
        fee = json["fee"].stringValue
        feeWithoutTax = json["fee_without_tax"].stringValue
        fileUrl = json["file_url"].stringValue
        isDataComplete = json["is_data_complete"].stringValue
        isTruth = json["is_truth"].stringValue
        itemType = json["item_type"].stringValue
        num = json["num"].stringValue
        productionDate = json["production_date"].stringValue
        remark = json["remark"].stringValue
        sellerAddressAndPhone = json["seller_address_and_phone"].stringValue
        sellerBankAccount = json["seller_bank_account"].stringValue
        sellerName = json["seller_name"].stringValue
        sellerTaxCode = json["seller_tax_code"].stringValue
        sourceType = json["source_type"].stringValue
        tax = json["tax"].stringValue
        time = json["time"].stringValue
        title = json["title"].stringValue
        type = json["type"].stringValue
        userId = json["user_id"].stringValue
    }

}
