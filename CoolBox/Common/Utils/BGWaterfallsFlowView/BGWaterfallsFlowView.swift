//
//  BGWaterfallsFlowView.swift
//  BGWaterfallsFlowViewDemo
//
//  Created by yangshebing on 2020/8/01.
//  Copyright © 2020 yangshebing. All rights reserved.
//

import UIKit

func UIColorFromHex(rgbValue:Int) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: 1.0)
}

//MARK: BGWaterfallsFlowViewDataSource

public protocol BGWaterfallsFlowViewDataSource: NSObjectProtocol {
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, numberOfItemsIn section:NSInteger) -> Int
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell;
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, heightForItemAt indexPath:IndexPath) -> CGFloat
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
}

//MARK: BGWaterfallsFlowViewDelegate

public protocol BGWaterfallsFlowViewDelegate: NSObjectProtocol {
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, didSelectItemAt indexPath:IndexPath)
}

extension BGWaterfallsFlowViewDelegate {
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, didSelectItemAt indexPath:IndexPath) {
    }
}
extension BGWaterfallsFlowViewDataSource {
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
}

public class BGWaterfallsFlowView: UIView, BGWaterfallsFlowLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    static let bgCollectionRefreshFooterView = "BGCollectionRefreshFooterView"
    static let bgScreenWidth = UIScreen.main.bounds.size.width
    static let bgScreenHeight = UIScreen.main.bounds.size.height
    static let footerHeight = 60
    
    public var columnNum: Int = 0 {
        didSet {
            waterFlowLayout?.columnNum = columnNum
        }
    }
    public var horizontalItemSpacing: CGFloat = 0.0 {
        didSet {
            waterFlowLayout?.horizontalItemSpacing = horizontalItemSpacing
        }
    }
    public var verticalItemSpacing: CGFloat = 0.0 {
        didSet {
            waterFlowLayout?.verticalItemSpacing = verticalItemSpacing
        }
    }
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            waterFlowLayout?.contentInset = contentInset
        }
    }
    
    public var itemWidth: CGFloat = 0 {
        didSet{
            waterFlowLayout?.itemWidth = itemWidth
        }
    }
    
    public var headerHeight: CGFloat = 0 {
        didSet{
            waterFlowLayout?.headerHeight = headerHeight
        }
    }
    
    public var footerHeight: CGFloat = 0 {
        didSet{
            waterFlowLayout?.footerHeight = footerHeight
        }
    }
    
  
    
    
    public weak var dataSource: BGWaterfallsFlowViewDataSource?
    public weak var delegate: BGWaterfallsFlowViewDelegate? {
        didSet {
            
        }
    }
    
    var collectionView: UICollectionView?
    private var waterFlowLayout: BGWaterfallsFlowLayout?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        let waterFlowLayout = BGWaterfallsFlowLayout()
        waterFlowLayout.columnNum = 4
        waterFlowLayout.horizontalItemSpacing = 15
        waterFlowLayout.verticalItemSpacing = 15
        waterFlowLayout.contentInset = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: waterFlowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        self.waterFlowLayout = waterFlowLayout
        self.collectionView = collectionView
        
    }
    
    //MARK: UICollectionView的公共方法
    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView?.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView?.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return (collectionView?.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath))!
    }
    
    public func dequeueReusableSupplementaryView(forSupplementaryViewOfKind kind: String, identifier: String, for indexPath: IndexPath) -> UICollectionReusableView {
        return (collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath))! as UICollectionReusableView
    }
    
    //注册头尾视图：xib  UICollectionView.elementKindSectionHeader/UICollectionView.elementKindSectionFooter
    public func register(_ nib: UINib?, forSupplementaryViewOfKind kind: String, identifier: String) {
        collectionView?.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
    ///注册头尾视图：非xib  UICollectionView.elementKindSectionHeader/UICollectionView.elementKindSectionFooter
    public func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind kind: String, identifier: String) {
        collectionView?.register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
    
    public func reloadData() {
        collectionView?.reloadData()
    }
    
    //MARK: UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource!.waterfallsFlowView(self, numberOfItemsIn: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource!.waterfallsFlowView(self, cellForItemAt: indexPath)
    }
    
    //MARK: UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.waterfallsFlowView(self, didSelectItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, _ layout: BGWaterfallsFlowLayout, heightForItemAt indexPath: IndexPath) -> CGFloat {
        return dataSource!.waterfallsFlowView(self, heightForItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return dataSource!.waterfallsFlowView(self, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }

}



