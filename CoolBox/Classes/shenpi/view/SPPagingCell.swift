//
//  SPPagingCell.swift
//  CoolBox
//
//  Created by 周志杰 on 2023/3/26.
//

import UIKit
@_exported import Parchment

struct SPPagingItem: PagingItem, Hashable, Comparable {

    var showRed: Bool
    
    let index: Int
    let title: String

    init(showRed: Bool, index: Int, title: String) {
        self.showRed = showRed
        self.index = index
        self.title = title
    }

    static func < (lhs: SPPagingItem, rhs: SPPagingItem) -> Bool {
        return lhs.index < rhs.index
    }
    
}

class SPPagingCell: PagingTitleCell {
    private var options: PagingOptions?

    lazy var readPoint: UILabel = {
        let readPoint = UILabel(frame: .zero)
        readPoint.backgroundColor = UIColor(hexString: "#F53F3F")
        readPoint.size = CGSize(width: 9, height: 9)
        readPoint.layer.cornerRadius = 4.5
        readPoint.masksToBounds = true
        return readPoint
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        addReadPoint()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
        addReadPoint()
    }
    
    func addReadPoint() {
        contentView.addSubview(readPoint)
        readPoint.snp.makeConstraints { make in
            make.left.equalTo(58)
            make.top.equalTo(6)
            make.size.equalTo(CGSize(width: 9, height: 9))
        }
        
    }

    override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
        guard let item = pagingItem as? SPPagingItem else { return }
        let paginTitleItem = PagingIndexItem(index: item.index, title: item.title)
        super.setPagingItem(paginTitleItem, selected: selected, options: options)
        readPoint.isHidden = !item.showRed
        
    }
  
}
