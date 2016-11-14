//
//  SplashViewController.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/29/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit
import Pixpie

let kSplashCompleteNotification = "kSplashNotification"

class SplashViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoView: UIImageView!
    var timer: Timer?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    deinit {
        PXP.sharedSDK().removeObserver(self, forKeyPath: "state")
    }

    func commonInit() {
        let options = NSKeyValueObservingOptions([.new, .initial])
        PXP.sharedSDK().addObserver(self, forKeyPath: "state", options: options, context: nil);
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.startAnimating();
    }

    override func viewWillDisappear(_ animated: Bool) {
        activityIndicator.stopAnimating()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if (object as! PXP == PXP.sharedSDK()) {
            timer?.invalidate()
            if (PXP.sharedSDK().state != .notInitialized) {
                timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(SplashViewController.splashCompleteAction(_:)), userInfo: nil, repeats: false)
            }
        }
    }

    func splashCompleteAction(_ note: Notification) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kSplashCompleteNotification), object: self)
    }
}
