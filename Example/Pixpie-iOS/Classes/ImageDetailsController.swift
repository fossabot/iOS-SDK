//
//  ImageDetailsController.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/12/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit

class ImageDetailsController: UIViewController {
    var url: NSString?

    @IBOutlet weak var imageView: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isBeingPresented || isMovingToParentViewController {
            guard let imageUrl = url
                else {return}
            imageView.pxp_requestImage(imageUrl as String, headers: nil, completion: { (url, image, error) in
                guard let toImage = image as! UIImage?
                    else { return }
                UIView.transition(with: self.imageView,
                    duration:0.25,
                    options: UIViewAnimationOptions.transitionCrossDissolve,
                    animations: { self.imageView.image = toImage },
                    completion: nil)
            })
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.pxp_cancelLoad()
    }
}
