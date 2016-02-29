//
//  AppDelegate.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/12/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit
import Pixpie_iOS

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        let options = NSKeyValueObservingOptions([.New, .Initial])
        PXP.sharedSDK().addObserver(self, forKeyPath: "state", options: options, context: nil);
        PXP.sharedSDK().authWithApiKey("5e451ae39c44cbe6085fd51e7f1b443abc49ffe150334fe0cc0902b6df23da95")
        self.window?.tintColor = UIColor.whiteColor()
        return true
    }

    deinit {
        PXP.sharedSDK().removeObserver(self, forKeyPath: "state", context: nil)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if (object as! PXP == PXP.sharedSDK()) {
            if (PXP.sharedSDK().state != PXPStateNotInitialized) {
                let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                self.window?.rootViewController = storyboard.instantiateInitialViewController()
            }
        }
    }

}
