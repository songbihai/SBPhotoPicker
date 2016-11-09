//
//  SBThreadsafely.swift
//  SBPhotoPickerDemo
//
//  Created by 宋碧海 on 16/8/31.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import Foundation

func dispatch_async_safely_to_main_queue(_ block: @escaping ()->()) {
    dispatch_async_safely_to_queue(DispatchQueue.main, block)
}

func dispatch_async_safely_to_queue(_ queue: DispatchQueue, _ block: @escaping ()->()) {
    if queue === DispatchQueue.main && Thread.isMainThread {
        block()
    } else {
        queue.async {
            block()
        }
    }
}

//swift没有Objective-C里的@synchronized
func synchronized(_ lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}
