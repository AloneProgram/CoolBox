//
//  BackgroundTimer.swift
//  LiveDemo
//
//  Created by winter on 2020/3/24.
//  Copyright © 2020 Yeting. All rights reserved.
//

import UIKit

public protocol BackgroundTimer {
    func resume()
    func suspend()
}

public class BackgroundTimerMaker {
    public typealias TimerTask = ()->()
    
    public static func makeTimer(adding: TimeInterval, task: TimerTask?) -> BackgroundTimer {
        return BackgroundTimerImp(deadline: .now() + adding, repeating: .never, task: task)
    }

    public static func makeTimer(adding: TimeInterval, repeatInterval: Int, task: TimerTask?) -> BackgroundTimer {
        return BackgroundTimerImp(deadline: .now() + adding, repeating: .seconds(repeatInterval), task: task)
    }

    public static func makeTimer(repeatInterval: Int, task: TimerTask?) -> BackgroundTimer {
        return BackgroundTimerImp(deadline: .now(), repeating: .seconds(repeatInterval), task: task)
    }
}

fileprivate class BackgroundTimerImp: BackgroundTimer {
    typealias TimerTask = BackgroundTimerMaker.TimerTask

    private var task: TimerTask?

    private let _timer: DispatchSourceTimer

    private let _lock = NSLock()

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    init(deadline: DispatchTime, repeating: DispatchTimeInterval = .never,
         leeway: DispatchTimeInterval = .milliseconds(100), task: TimerTask?) {
        self.task = task
        _timer = DispatchSource.makeTimerSource()
        _timer.schedule(deadline: deadline,
                        repeating: repeating,
                        leeway: leeway)
        _timer.setEventHandler(handler: {
            task?()
        })
    }

    func resume() {
        guard state != .resumed else { return }
        _lock.lock()
        defer {
            _lock.unlock()
        }
        guard state != .resumed else { return }
        state = .resumed
        _timer.resume()
    }

    func suspend() {
        guard state != .suspended else { return }
        _lock.lock()
        defer {
            _lock.unlock()
        }
        guard state != .suspended else { return }
        state = .suspended
        _timer.suspend()
    }

    deinit {
        _timer.setEventHandler {}
        _timer.cancel()
        // cancel 之后 再 resume，可以解决不能释放问题
        resume()
        task = nil
        print("deinit timer source")
    }
}
