//
//  ChangeSubsidyStandardVC.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/4/8.
//

import UIKit

class ChangeSubsidyStandardVC: EViewController {
    
    @IBOutlet weak var dayBtn: UIButton!
    
    @IBOutlet weak var halfDaybtn: UIButton!
    
    
    @IBOutlet weak var firstDayLabel: UILabel!
    
    @IBOutlet weak var fistLineCity: UILabel!
    
    @IBOutlet weak var firtstLineTF: UITextField!
    
    
    @IBOutlet weak var secondLineTF: UITextField!
    
    @IBOutlet weak var seconDayLabel: UILabel!
    
    @IBOutlet weak var seconCityLabel: UILabel!
    
    
    @IBOutlet weak var otherCityTF: UITextField!
    
    @IBOutlet weak var otherDayLabel: UILabel!
    
    
    var config: SubsidyConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftTitle = "修改出差补贴标准"
        
        firtstLineTF.tag = 1
        firtstLineTF.delegate = self
        secondLineTF.tag = 2
        secondLineTF.delegate = self
        otherCityTF.tag = 2
        otherCityTF.delegate = self
        
        getConfig()
    }
    
    func getConfig() {
        BXApi.getSubsidyConfig { [weak self] config in
            self?.config = config
            self?.configView()
        }
    }
    
    func configView() {
        guard let config = config else {
            return
        }
        dayBtn.isSelected = config.type == "1"
        halfDaybtn.isSelected = !dayBtn.isSelected
        
        
        if config.type == "1" {
            firstDayLabel.text = "元/天"
            seconDayLabel.text = "元/天"
            otherDayLabel.text = "元/天"
        }else {
            firstDayLabel.text = "元/半天"
            seconDayLabel.text = "元/半天"
            otherDayLabel.text = "元/半天"
        }
        
        firtstLineTF.text = config.travelFirstCityFee
        secondLineTF.text = config.travelSecondCityFee
        otherCityTF.text = config.travelOtherCityFee
        
        fistLineCity.text = config.firstCity
        seconCityLabel.text = config.secondCity
    }


    @IBAction func selectDayAction(_ sender: Any) {
        config?.type = "1"
        configView()
    }
    
    @IBAction func selectHalfDayAction(_ sender: Any) {
        config?.type = "2"
        configView()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let config = config else { return }
        let params: [String: String] = [
            "other_city": config.travelFirstCityFee,
            "first_city": config.travelSecondCityFee,
            "type": config.type,
            "second_city": config.travelOtherCityFee
        ]
        BXApi.saveSubsidyConfig(params: params) {[weak self] success in
            if success {
                self?.popViewController()
            }
        }
    }
    
    
}

extension ChangeSubsidyStandardVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 1: config?.travelFirstCityFee = textField.text ?? ""
        case 2: config?.travelSecondCityFee = textField.text ?? ""
        case 3: config?.travelOtherCityFee = textField.text ?? ""
        default:
            break;
        }
    }
}
