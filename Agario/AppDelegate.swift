//
//  AppDelegate.swift
//  Agario
//
//  Created by Michaelin on 15/8/17.
//  Copyright (c) 2015年 Michaelin. All rights reserved.
//

import UIKit

let playerCategory:UInt32 =  0x1 << 1
let foodCategory:UInt32 =  0x1 << 2
let aiPlayerCategory:UInt32 = 0x1 << 4
let boundaryCategory:UInt32 = 0x1 << 8
let obstacleCategory:UInt32 = 0x1 << 16

let COMPARE_RATE:CGFloat = 0.9
let PLAYER_SIZE:CGFloat = 20
let AIPLAYER_SIZE:CGFloat = 20
let FOOD_SIZE:CGFloat = 10
let OBSTACLE_SIZE:CGFloat = 60
let WIDTH:CGFloat = 3333
let HEIGHT:CGFloat = 3333
let SEARCH_RANGE:CGFloat = 10
let MERGE_TIME:Double = 10

let AIPLAYER_QTY = 6
let OBSTACLE_QTY = 6
let FOOD_QTY = 333

let removeNodeQueue = dispatch_queue_create("removeNodeQueue", DISPATCH_QUEUE_SERIAL)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

