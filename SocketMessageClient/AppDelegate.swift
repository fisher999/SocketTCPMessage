//
//  AppDelegate.swift
//  SocketMessageClient
//
//  Created by Victor on 25.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let controller  = MainController(withHost: "127.0.0.1", port: 2000)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = controller
        self.window?.makeKeyAndVisible()
        return true
    }
}

