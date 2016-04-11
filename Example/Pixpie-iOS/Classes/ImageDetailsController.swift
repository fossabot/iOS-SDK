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
            imageView.pxp_requestImage(imageUrl, headers: nil, completion: { (url, image, error) in
                guard let toImage = image
                    else { return }
                UIView.transitionWithView(self.imageView,
                    duration:0.25,
                    options: UIViewAnimationOptions.TransitionCrossDissolve,
                    animations: { self.imageView.image = toImage },
                    completion: nil)
            })
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
}
