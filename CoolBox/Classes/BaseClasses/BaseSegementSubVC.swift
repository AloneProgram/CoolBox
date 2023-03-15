//
//  BaseSegementSubVC.swift
//  huandian
//
//  Created by Jhin on 2020/9/16.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit
@_exported import SegementSlide

class BaseSegementSubVC: UIViewController, SegementSlideDefaultSwitcherViewDelegate, SegementSlideContentDelegate {

    private var segementSlideSwitcherView: SegementSlideDefaultSwitcherView!
    private var segementSlideContentView: SegementSlideContentView!
    
    public var switcherConfig: SegementSlideDefaultSwitcherConfig {
        return SegementSlideDefaultSwitcherConfig()
    }
    
    public var slideHeight: CGFloat {
        return 28
    }
    public var slideBottomHeight: CGFloat {
        return 10
    }
    
    public var switcherBgColor: UIColor {
        return .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard segementSlideSwitcherView.superview != nil else { return }
        segementSlideSwitcherView.snp.remakeConstraints { make in
            make.left.top.equalToSuperview()
            make.height.equalTo(slideHeight)
            make.width.equalTo(kScreenWidth)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSwitcherView()
        setupContentView()
    }
    

    private func setupSwitcherView() {
        segementSlideSwitcherView = SegementSlideDefaultSwitcherView()
        segementSlideSwitcherView.config = switcherConfig
        segementSlideSwitcherView.delegate = self
        segementSlideSwitcherView.backgroundColor = switcherBgColor
        
        view.addSubview(segementSlideSwitcherView)
        segementSlideSwitcherView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalToSuperview()
            make.height.equalTo(slideHeight)
            make.width.equalTo(kScreenWidth - 20)
        }
     }
     
    private func setupContentView() {
        segementSlideContentView = SegementSlideContentView()
        segementSlideContentView.delegate = self
        segementSlideContentView.backgroundColor = UIColor(rgb: 245)
        segementSlideContentView.viewController = self
        view.addSubview(segementSlideContentView)
        segementSlideContentView.snp.makeConstraints { make in
            make.top.equalTo(slideHeight + slideBottomHeight)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
    func reloadSwitcherView(){
        segementSlideSwitcherView.reloadData()
    }
    
    func reloadData() {
        segementSlideSwitcherView.reloadData()
        segementSlideContentView.reloadData()
    }
    
    func scrollToSlide(at index: Int, animated: Bool) {
        segementSlideSwitcherView.selectItem(at: index, animated: animated)
    }
    
    deinit { }
    
    
    //------SegementSlideDefaultSwitcherViewDelegate--------
    func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideDefaultSwitcherView, didSelectAtIndex index: Int, animated: Bool) {
        if segementSlideContentView.selectedIndex != index {
            segementSlideContentView.selectItem(at: index, animated: animated)
        }
    }
    
    func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideDefaultSwitcherView, showBadgeAtIndex index: Int) -> BadgeType {
        return .none
    }
    
     public var titlesInSegementSlideSwitcherView: [String] {
        return []
    }
    
    
    //------SegementSlideContentDelegate--------
    public var segementSlideContentScrollViewCount: Int {
        return titlesInSegementSlideSwitcherView.count
    }
    
    public func segementSlideContentScrollView(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        return UIViewController() as? SegementSlideContentScrollViewDelegate
    }
    
    public func segementSlideContentView(_ segementSlideContentView: SegementSlideContentView, didSelectAtIndex index: Int, animated: Bool) {
        if segementSlideSwitcherView.selectedIndex != index {
            segementSlideSwitcherView.selectItem(at: index, animated: animated)
        }
    }
}
