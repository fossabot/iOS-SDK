//
//  AppDelegate.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/12/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit
import Pixpie
import Fabric
import Crashlytics

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        Fabric.with([Crashlytics.self])
        let defaultLicense = "5e451ae39c44cbe6085fd51e7f1b443abc49ffe150334fe0cc0902b6df23da95"
        NSUserDefaults.standardUserDefaults().registerDefaults(["pxp_license" : defaultLicense])

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.splashCompleted(_:)), name: kSplashCompleteNotification, object: nil)
        let license = NSUserDefaults.standardUserDefaults().stringForKey("pxp_license")
        PXP.sharedSDK().authWithApiKey(license)
        self.window?.tintColor = UIColor.whiteColor()
        return true
    }

    deinit {
        PXP.sharedSDK().removeObserver(self, forKeyPath: "state", context: nil)
    }

    func splashCompleted(note: NSNotification) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
    }
}
