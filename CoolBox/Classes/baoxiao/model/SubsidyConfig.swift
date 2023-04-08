//
//  SubsidyConfig.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/8.
//

import UIKit

struct SubsidyConfig {

    var firstCity = ""
    var secondCity = ""

    var travelFirstCityFee = ""
    var travelOtherCityFee = ""
    var travelSecondCityFee = ""
    var type = ""


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        travelFirstCityFee = json["travel_subsidy"]["travel_first_city_fee"].stringValue
        travelOtherCityFee = json["travel_subsidy"]["travel_other_city_fee"].stringValue
        travelSecondCityFee = json["travel_subsidy"]["travel_second_city_fee"].stringValue
        type = json["travel_subsidy"]["type"].stringValue
        
        firstCity = json["travel_subsidy_data"]["first_city"].stringValue
        secondCity = json["travel_subsidy_data"]["second_city"].stringValue
    }


}
