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
        PXP.sharedSDK().authWithApiKey("5e451ae39c44cbe6085fd51e7f1b443abc49ffe150334fe0cc0902b6df23da95")
        return true
    }

}
