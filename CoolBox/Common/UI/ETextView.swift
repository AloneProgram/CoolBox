//
//  ETextView.swift
//  huandian
//
//  Created by Jhin on 2020/11/11.
//  Copyright © 2020 immptor. All rights reserved.
//

import UIKit

class ETextView: UIView {

    typealias CallBack = (_ text: String, _ result: Bool) -> Void
    /// 输入改变时的回调
    var callBack: CallBack?
    
    /// 最大字数 - 默认30
    var maxWords: Int = 30 {
        didSet {
            let text = "\(defaultText.count)/\(maxWords)"
            numLabel.text = text
        }
    }
    
    // ---------- 背景 ----------
    /// 背景色 - 默认白色
    var bgColor: UIColor = .white {
        didSet {
            bgImgView.backgroundColor = bgColor
        }
    }
    
    /// 本地存放背景图片
    var bgLocalImg: String? {
        didSet {
            bgImgView.image = UIImage(named: bgLocalImg!)
        }
    }
    
    /// 网络获取背景图片
    var bgRemoteImg: String? {
        didSet {
            bgImgView.kf.setImage(with: URL(string: bgRemoteImg!))
        }
    }
    
    // ---------- 字体颜色 ----------
    /// textView字体颜色 - 默认黑色
    var textColor: UIColor = .black {
        didSet {
            textView.textColor = textColor
        }
    }
    
    /// 占位文本颜色 - 默认灰色
    var placeholderTextColor: UIColor = .gray {
        didSet {
            placeholderLabel.textColor = placeholderTextColor
        }
    }
    
    /// 显示字数 label 颜色 - 默认灰色
    var numLabelTextColor: UIColor = .gray {
        didSet {
            numLabel.textColor = numLabelTextColor
        }
    }
    
    // ---------- 字体 ----------
    /// textView字体 - 默认15
    var textFont: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            textView.font = textFont
        }
    }
    
    /// 占位字体 - 默认15
    var placeholderTextFont: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            placeholderLabel.font = placeholderTextFont
        }
    }
    
    /// 字数限制字体 - 默认12
    var numLabelTextFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            numLabel.font = numLabelTextFont
        }
    }
    
    // ---------- 文本 ----------
    /// 占位文本 - 默认"请输入..."
    var placeHolderText: String = "请输入..." {
        didSet {
            placeholderLabel.text = placeHolderText
//            let height = placeHolderText.heightWithConstrainedWidth(width: kScreenWidth - 60, font: placeholderLabel.font) + 3
//            placeholderLabel.snp.updateConstraints { (make) in
//                make.height.equalTo(height)
//            }
        }
    }
    
    /// 默认文本
    var defaultText: String = "" {
        didSet {
            let attributeString = NSAttributedString(string: defaultText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
            
            textView.attributedText = attributeString
            placeholderLabel.isHidden = true
            let tempStr = textView.attributedText
            let text = "\(tempStr?.length ?? 0)/\(maxWords)"
            numLabel.text = text
        }
    }
    
    /// 已经输入的文本
    var text: String {
        return textView.text
    }
    
    ///传入文本
    var inputText: String? {
        didSet {
            textView.text = inputText
            placeholderLabel.isHidden = inputText?.length ?? 0 > 0
            numLabel.text = "\(inputText?.length ?? 0)/\(maxWords)"
        }
    }
    
    /// 传入富文本
    var inputAttritStr: NSAttributedString? {
        didSet {
            textView.attributedText = inputAttritStr
        }
    }
    
    /// 隐藏字数提示
    var hideNumLabel: Bool = false {
        didSet {
            numLabel.isHidden = hideNumLabel
        }
    }
    
    /// w文本框是否能编辑
    var canEdit: Bool = true {
        didSet {
            textView.isEditable = canEdit
        }
    }
    
    
    // MARK: - 私有属性
    
    /// 容器view
    lazy private var contentView: UIView = {
       let contentView = UIView()
        return contentView
    }()
    
    /// 背景view
    lazy private var bgImgView: UIImageView = {
        let bgImgView = UIImageView()
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.clipsToBounds = true
        return bgImgView
    }()
    
    /// 输入框
    lazy private var textView: UITextView = {
       let textView = UITextView()
        textView.backgroundColor = .clear
//        textView.tintColor = UIColor(hexString: "#FF7513")
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 7, bottom: 0, right: 0)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textViewEditChanged(_:)),
            name: NSNotification.Name(rawValue: "UITextViewTextDidChangeNotification"),
            object: textView
        )
        return textView
    }()
    
    /// 字数限制提示文本
    lazy private var numLabel: UILabel = {
        let numLabel = UILabel()
        numLabel.textAlignment = .right
        numLabel.alpha = 0.7
        return numLabel
    }()
    
    /// 占位文本
    lazy private var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.numberOfLines = 0
        return placeholderLabel
    }()
    
    
    // MARK: - Initialize
    init() {
        super.init(frame: .zero)
        setupLayout()
        setupDefaultValue()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupDefaultValue()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupDefaultValue() {
        maxWords = 30
        bgColor = .white
        textColor = .black
        placeholderTextColor = .gray
        numLabelTextColor = .gray
        textFont = UIFont.systemFont(ofSize: 16)
        placeholderTextFont = UIFont.systemFont(ofSize: 12)
        placeHolderText = "请输入..."
    }
    
    /// 布局
    private func setupLayout() {
        
        // 容器view
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        // 背景视图
        contentView.addSubview(bgImgView)
        bgImgView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        // textView
        contentView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-45)
        }
        
        // 字数限制文本
        contentView.addSubview(numLabel)
        numLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-15)
            make.bottom.equalTo(contentView).offset(-12.5)
            make.width.equalTo(100)
            make.height.equalTo(13)
        }
        
        // 占位文本
        textView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(13)
            make.top.equalToSuperview().offset(11)
//            make.width.equalTo(260)
            make.right.equalTo(contentView).offset(-13)
//            make.height.equalTo(16)
        }
        
    }
}

// MARK: - Notification Method
extension ETextView {
    @objc func textViewEditChanged(_ obj: Notification) {
        let textView: UITextView = obj.object as! UITextView
        if let text = textView.text {
            placeholderLabel.isHidden = text.length > 0
        }
        guard let _: UITextRange = textView.markedTextRange else{
            if let str = textView.text, str.count > maxWords {
                textView.text = str.subString(start: 0, length: maxWords)
            }
            callBack?(textView.text, true)
            numLabel.text = "\(textView.text.count)/\(maxWords)"
            return
        }
        
    }
    
}
