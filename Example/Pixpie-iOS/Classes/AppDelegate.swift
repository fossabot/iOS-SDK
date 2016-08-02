//
//  AppDelegate.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/12/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit
import HockeySDK

//import Fabric
//import Crashlytics

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("1281ec03743d493bb76953318bb49bf4")
        // Do some additional configuration if needed here
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()

        //Fabric.with([Crashlytics.self])
        let defaultLicense = "41bc38fde0dfed6917b6f54fdc32761ac2d9e7eb6cd66b8591e586e6fc6b9063"
        NSUserDefaults.standardUserDefaults().registerDefaults(["pxp_license" : defaultLicense])
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.splashCompleted(_:)), name: kSplashCompleteNotification, object: nil)
        PixpieManager.cleanUp();
        PixpieManager.authorize();
        self.window?.tintColor = UIColor.whiteColor()
        return true
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kSplashCompleteNotification, object: nil)
    }

    func splashCompleted(note: NSNotification) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
    }
}
