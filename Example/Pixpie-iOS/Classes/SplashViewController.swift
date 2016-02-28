//
//  SplashViewController.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/29/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        activityIndicator.startAnimating();
    }

    override func viewWillDisappear(animated: Bool) {
        activityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
