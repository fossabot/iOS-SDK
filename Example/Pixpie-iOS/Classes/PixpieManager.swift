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
        guard let license = UserDefaults.standard.string(forKey: "pxp_license")
            else {return}
        PXP.sharedSDK().auth(withApiKey: license)
    }

    static func cleanUp() {
        PXP.cleanUp()
    }

}
