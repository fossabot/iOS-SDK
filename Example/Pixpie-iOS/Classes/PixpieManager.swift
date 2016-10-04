//
//  PixpieManager.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 8/2/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import Foundation
import Pixpie

class PixpieManager: NSObject {
    
    static func authorize() {
        guard let license = NSUserDefaults.standardUserDefaults().stringForKey("pxp_license")
            else {return}
        PXP.sharedSDK().authWithApiKey(license)
    }

    static func cleanUp() {
        PXP.cleanUp()
    }

}
