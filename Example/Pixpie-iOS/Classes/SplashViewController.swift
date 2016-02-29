//
//  SplashViewController.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/29/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit
import Pixpie_iOS

let kSplashCompleteNotification = "kSplashNotification"

class SplashViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoView: UIImageView!
    var timer: NSTimer?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    deinit {
        PXP.sharedSDK()
        PXP.sharedSDK().removeObserver(self, forKeyPath: "state")
    }

    func commonInit() {
        let options = NSKeyValueObservingOptions([.New, .Initial])
        PXP.sharedSDK().addObserver(self, forKeyPath: "state", options: options, context: nil);
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        activityIndicator.startAnimating();
    }

    override func viewWillDisappear(animated: Bool) {
        activityIndicator.stopAnimating()
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if (object as! PXP == PXP.sharedSDK()) {
            timer?.invalidate()
            if (PXP.sharedSDK().state != PXPStateNotInitialized) {
                timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "splashCompleteAction:", userInfo: nil, repeats: false)
            }
        }
    }

    func splashCompleteAction(note: NSNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName(kSplashCompleteNotification, object: self)
    }
}
