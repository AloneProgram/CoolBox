//
//  CusSlideView.swift
//  huandian
//
//  Created by Jhin on 2020/9/8.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

enum SlideType {
    case videoCollection  //视频征集
    case merchOrder  //商家订单
    case dataSta   //数据统计
    
    var leftTitle: String{
        switch self {
        case .videoCollection: return "我的征集"
        case .merchOrder: return "我发布的商品"
        case .dataSta: return "用户数据"
        }
    }
    
    var rightTitle: String{
        switch self {
        case .videoCollection: return "我投稿"
        case .merchOrder: return "我预订的商品"
        case .dataSta: return "订单数据"
        }
    }
    
//    var leftImage: UIImage {
//        switch self {
//        case .videoCollection: return "我的征集"
//        case .merchOrder: return "我发布的商品"
//        case .dataSta: return "用户数据"
//        }
//    }
//
//    var rightImage: UIImage{
//        switch self {
//        case .videoCollection: return "我投稿"
//        case .merchOrder: return "我预订的商品"
//        case .dataSta: return "订单数据"
//        }
//    }
}

class CusSlideView: UIView {
    
    
    
    
    init() {
        super.init(frame: .zero)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

fileprivate class NorButton: LeftImageButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let corners: UIRectCorner = [.topLeft, .topRight]
        let radius: CGFloat = 8
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
