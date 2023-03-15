//
//  Stack.swift
//  Livepush
//
//  Created by winter on 2020/4/7.
//  Copyright © 2020 yeting. All rights reserved.
//

import Foundation

protocol StackP {
    /// 持有的元素类型
    associatedtype Element
    
    /// 是否为空
    var isEmpty: Bool { get }
    /// 栈的大小
    var size: Int { get }
    /// 栈顶元素
    var peek: Element? { get }
    
    /// 进栈
    mutating func push(_ newElement: Element)
    /// 出栈
    mutating func pop() -> Element?
    ///清空栈
    mutating func clear()
}

struct Stack<T>: StackP {
    typealias Element = T
    
    var isEmpty: Bool { return stack.isEmpty }
    var size: Int { return stack.count }
    var peek: Element? { return stack.last }
    
    private var stack = [Element]()
    
    mutating func push(_ newElement: Element) {
        stack.append(newElement)
    }
    
    mutating func pop() -> Element? {
        return stack.popLast()
    }
    
    mutating func clear() {
        stack.removeAll()
    }
}
