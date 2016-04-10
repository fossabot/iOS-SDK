//
//  ImageDetailsController.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/12/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit

class ImageDetailsController: UIViewController {
    var url: NSURL?

    @IBOutlet weak var imageView: UIImageView!
    override func viewWillAppear(animated: Bool) {
        if isBeingPresented() || isMovingToParentViewController() {
            guard let imageUrl = url
                else {return}
            imageView.pxp_requestImage(imageUrl, headers: nil)
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
}
