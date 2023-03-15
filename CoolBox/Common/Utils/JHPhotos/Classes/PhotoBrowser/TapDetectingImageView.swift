//
//  TapDetectingImageView.swift
//  JHPhotos
//
//  Created by winter on 2017/6/23.
//  Copyright © 2017年 DJ. All rights reserved.
//

import UIKit

protocol TapDetectingImageViewDelegate: class {
    func imageView(_ imageView: UIImageView, singleTapDetected touchPoint: CGPoint)
    func imageView(_ imageView: UIImageView, doubleTapDetected touchPoint: CGPoint)
//    func imageView(_ imageView: UIImageView, tripleTapDetected touchPoint: CGPoint) {}
    func imageView(_ imageView: UIImageView, longTapDetected touchPoint: CGPoint)
}

extension TapDetectingImageViewDelegate {
    func imageView(_ imageView: UIImageView, singleTapDetected touchPoint: CGPoint) {}
    func imageView(_ imageView: UIImageView, doubleTapDetected touchPoint: CGPoint) {}
//    func imageView(_ imageView: UIImageView, tripleTapDetected touchPoint: CGPoint) {}
    func imageView(_ imageView: UIImageView, longTapDetected touchPoint: CGPoint) {}
}

class TapDetectingImageView: UIImageView {
    
    weak var tapDelegate: TapDetectingImageViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        self.addGestureRecognizer()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        isUserInteractionEnabled = true
        self.addGestureRecognizer()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        isUserInteractionEnabled = true
        self.addGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addGestureRecognizer() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapDetected(_:)))
        self.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapDetected(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        // 双击时，单击失效
        singleTap.require(toFail: doubleTap)
        
//        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(tripleTapDetected(_:)))
//        tripleTap.numberOfTapsRequired = 3
//        self.addGestureRecognizer(tripleTap)
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTapDetected(_:)))
        longTap.minimumPressDuration = 1
        self.addGestureRecognizer(longTap)
        singleTap.require(toFail: longTap)
    }
}

@objc private extension TapDetectingImageView {
    
    func singleTapDetected(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: self)
        tapDelegate?.imageView(self, singleTapDetected: touchPoint)
    }
    
    func doubleTapDetected(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: self)
        tapDelegate?.imageView(self, doubleTapDetected: touchPoint)
    }
    
    //    func tripleTapDetected(_ gesture: UITapGestureRecognizer) {
    //        let touchPoint = gesture.location(in: self)
    //        tapDelegate?.imageView!(self, tripleTapDetected: touchPoint)
    //    }
    
    func longTapDetected(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let touchPoint = gesture.location(in: self)
        tapDelegate?.imageView(self, longTapDetected: touchPoint)
    }
}
