//
//  CountdownTool.swift
//  huandian
//
//  Created by jhin on 2020/12/14.
//  Copyright © 2020 immptor. All rights reserved.
//

import UIKit

struct CountdownTool {
    
    static private var timers = [String: CountdownHandle]()
    
    /// 必须手动 调用 stop(forKey)
    static func start(timeInterval: Int, key: String, handler: @escaping (Int) -> Void) {
        stop(forKey: key)
        let timer = CountdownHandle(forKey: key, seconds: timeInterval)
        CountdownTool.timers[key] = timer
        timer.fire(handler: handler)
    }
    
    static func pause(forkey: String) {
        guard let timer = CountdownTool.timers[forkey] else { return }
        timer.pause()
    }
    
    static func stop(forKey: String) {
        guard let timer = CountdownTool.timers[forKey] else { return }
        timer.cancel()
        CountdownTool.timers.removeValue(forKey: forKey)
    }
}

private class CountdownHandle {
    var timer: DispatchSourceTimer
    var timeCountdown = 0 //倒计时时间
    var key = "key"

    init(forKey: String, seconds: Int) {
        self.key = forKey
        self.timeCountdown = seconds
        
        let queue = DispatchQueue.global(qos: .default)
        let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        self.timer = timer
    }
    
    func fire(handler: @escaping (Int) -> Void) {
        let timer = self.timer
        timer.schedule(wallDeadline: .now(), repeating: DispatchTimeInterval.seconds(1))
        timer.setEventHandler { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.timeCountdown <= 0 {
                // 倒计时结束
                strongSelf.cancel()
            }
            else {
                strongSelf.timeCountdown -= 1
            }
            DispatchQueue.main.async {
                handler(strongSelf.timeCountdown)
            }
        }
        timer.resume()
    }
    
    func pause() {
        self.timer.suspend()
    }
    
    func cancel(){
        self.timer.cancel()
    }
}
