//
//  DatePicker.swift
//  huandian
//
//  Created by jhin on 2020/12/17.
//  Copyright © 2020 immptor. All rights reserved.
//

import UIKit

class DatePicker: PresentBottomVC {
    
    typealias DatePickerClosure = (_ dateStr: String) -> Void
    private var datePickerClosure: DatePickerClosure?
    
    private var dateArr: [String] = []
    
    private var selectDate: String?
    
    private var pickerView = UIDatePicker()
    
    private var pickerModel: UIDatePicker.Mode = .date
    
    override var enableTouchToDismiss: Bool {
        return true
    }
    
    override var controllerHeight: CGFloat {
        return 240 + kBottomSpace
    }
    
    init(_ model: UIDatePicker.Mode? = .date, handle: DatePickerClosure? = nil) {
        pickerModel = model ?? .date
        datePickerClosure = handle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        let canleBtn = UIButton(type: .custom)
        canleBtn.setTitle("取消", for: .normal)
        canleBtn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        canleBtn.titleLabel?.font = Font(16)
        canleBtn.addTarget(self, action: #selector(cancleAction), for: .touchUpInside)
        view.addSubview(canleBtn)
        canleBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(20)
            make.height.equalTo(20)
            make.width.equalTo(40)
        }
        
        
        let sureBtn = UIButton(type: .custom)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(UIColor(hexString: "#165DFF"), for: .normal)
        sureBtn.titleLabel?.font = Font(16)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        view.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.top.equalTo(15)
            make.height.equalTo(30)
            make.width.equalTo(40)
        }
        
        //设置显示模式为日期时间
        if #available(iOS 13.4, *) {
            pickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        pickerView.datePickerMode = pickerModel
        pickerView.maximumDate = Date()//设置最大值为现在
        view.addSubview(pickerView)
        pickerView.snp.makeConstraints {
            $0.top.equalTo(50)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(-kBottomSpace)
        }
    }

    @objc func sureAction() {
        let date = pickerView.date//获取选定的值
        //初始化日期格式化对象
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh")
        //设置日期格式化对象的具体格式
        if pickerModel == .date {
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }else if pickerModel == .dateAndTime {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        
        //将选定的值转换为string格式以设定格式输出
        let dateStr = dateFormatter.string(from: date)
        dismiss(animated: true) {[weak self] in
            self?.datePickerClosure?(dateStr)
        }
        
    }

    @objc func cancleAction(){
        dismiss(animated: true, completion: nil)
    }
}
