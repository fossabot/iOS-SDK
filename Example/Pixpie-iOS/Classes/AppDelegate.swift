//
//  AppDelegate.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/12/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let defaultLicense = "41bc38fde0dfed6917b6f54fdc32761ac2d9e7eb6cd66b8591e586e6fc6b9063"
        UserDefaults.standard.register(defaults: ["pxp_license" : defaultLicense])
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.splashCompleted(_:)), name: NSNotification.Name(rawValue: kSplashCompleteNotification), object: nil)
        PixpieManager.cleanUp();
        PixpieManager.authorize();
        self.window?.tintColor = UIColor.white
        return true
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kSplashCompleteNotification), object: nil)
    }

    func splashCompleted(_ note: Notification) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
    }
}
