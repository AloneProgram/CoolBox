//
//  Queue.swift
//  huandian
//
//  Created by Jhin on 2020/9/7.
//  Copyright © 2020 immotor. All rights reserved.
//

import UIKit

protocol QueueP {
    /// 持有的元素类型
    associatedtype Element
    
    /// 是否为空
    var isEmpty: Bool { get }
    /// 队列的大小
    var size: Int { get }
    /// 队列最前面元素
    var front: Element? { get }
    
    /// 入队
    mutating func enqueue(_ newElement: Element)
    /// 出队
    mutating func dequeue() -> Element?
}

// 队列 FIFO
public struct Queue<T>: QueueP {
    typealias Element = T
    
    private var queue = [Element?]()
    private var head = 0
    
    var isEmpty: Bool { return size == 0 }
    var size: Int { return queue.count - head }
    
    var front: T? {
        if isEmpty { return nil }
        else { return queue[head] }
    }
    
    mutating func enqueue(_ newElement: T) {
        queue.append(newElement)
    }
    
    mutating func dequeue() -> T? {
        guard head < queue.count, let element = queue[head] else { return nil }

        queue[head] = nil
        head += 1

        let percentage = Double(head)/Double(queue.count)
        // 数组大小超过 50 时，空点占比超过30% 对数组调整
        if queue.count > 50 && percentage > 0.3 {
            queue.removeFirst(head)
            head = 0
        }

        return element
    }
}
