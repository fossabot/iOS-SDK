//
//  ImagesViewController.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/12/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit
import Pixpie
import PXStatusView
import InAppSettingsKit

private let kCellIdentifier = "kImageCell"
private let kSectionsCount = 1
private let kDetailsSegue = "DetailsSegue"

class ImagesViewController: UICollectionViewController, IASKSettingsDelegate {

    @IBOutlet weak var statusView: PXStatusView!
    let imageLinksArray = kImageLinkArray
    var pickedUrl: NSURL?

    var graphView : PXGraphView?
    
    var timer : NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        //collectionView?.registerClass(ImageCell.self, forCellWithReuseIdentifier: kCellIdentifier)
        self.configStatusView()
        
        self.graphView = PXGraphView.init(frame: CGRect.init(x: 0, y: self.view.frame.maxY - 100, width: self.view.frame.width, height: 100))
        self.graphView?.backgroundColor = UIColor.whiteColor()
        self.graphView?.pointsNumber = 60
        self.graphView?.alpha = 0.65
        self.view.addSubview(self.graphView!)
        let ti = Int(NSDate.timeIntervalSinceReferenceDate()) + 1
        self.timer = NSTimer.init(fireDate: NSDate.init(timeIntervalSinceReferenceDate: NSTimeInterval(ti)), interval: 1, target: self, selector: #selector(updateGraph), userInfo: nil, repeats: false)
        let runloop = NSRunLoop.currentRunLoop()
        runloop.addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
        
        self.navigationItem.title = "0b"
        
        let options = NSKeyValueObservingOptions([.New, .Initial])
        PXPTrafficMonitor.sharedMonitor().addObserver(self, forKeyPath: "totalBytesForSession", options: options, context: nil)
    }
    
    func updateGraph() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.graphView?.addPoint(PXPTrafficMonitor.sharedMonitor().lastSample)
            self.updateGraph()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(true, animated: animated)
        let options = NSKeyValueObservingOptions([.New, .Initial])
        PXP.sharedSDK().addObserver(self, forKeyPath: "state", options: options, context: nil);
    }

    override func viewWillDisappear(animated: Bool) {
        PXP.sharedSDK().removeObserver(self, forKeyPath: "state")
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return kSectionsCount
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if (object as? PXP == PXP.sharedSDK()) {
            self.configStatusView()
        }
        else if (object as? PXPTrafficMonitor == PXPTrafficMonitor.sharedMonitor()) {
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationItem.title = self.transformedValue(PXPTrafficMonitor.sharedMonitor().totalBytesForSession)
            })
        }
    }
    
    func configStatusView() {
        self.statusView.backgroundColor = UIColor.clearColor()
        switch PXP.sharedSDK().state {
        case PXPStateReady:
            self.statusView.state = .Green
        case PXPStateFailed:
            self.statusView.state = .Red
        default:
            self.statusView.state = .Yellow
        }
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kImageLinkArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ImageCell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: indexPath) as! ImageCell
        var urlString = imageLinksArray[indexPath.item]
        if let range = urlString.rangeOfString("_z.jpg"){
            urlString.replaceRange(range, with: "_q.jpg")
        }
        let url = NSURL(string: urlString)
        let transform = PXPTransform(imageView: cell.imageView!)
        transform.fitSize = CGSize(width: 100.0, height: 100.0)
        cell.imageView?.pxp_transform = transform
        cell.imageView?.pxp_requestImage(url!, headers: nil, completion: { (url, image, error) in
            guard let toImage = image
                else { return }
            guard let imageView = cell.imageView
                else { return }

            UIView.transitionWithView(imageView,
                duration:0.25,
                options: UIViewAnimationOptions.TransitionCrossDissolve,
                animations: { imageView.image = toImage },
                completion: nil)
        })
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.pickedUrl = NSURL(string: imageLinksArray[indexPath.item])
        performSegueWithIdentifier(kDetailsSegue, sender: collectionView)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == kDetailsSegue) {
            let detailsController = segue.destinationViewController as! ImageDetailsController
            detailsController.url = self.pickedUrl
        }
    }

    func itemSize() -> CGSize {
        let itemSize = CGSizeMake(self.view.frame.width/4.0, self.view.frame.width/4.0)
        return itemSize
    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return self.itemSize()
    }

    @IBAction func settingsAction(sender: AnyObject) {
        let settingsVC = SettingsViewController()
        settingsVC.delegate = self
        let navigationController = UINavigationController(rootViewController: settingsVC)
        navigationController.view.tintColor = UIColor.blueColor()
        self.presentViewController(navigationController, animated: true, completion: nil)
    }

    func settingsViewControllerDidEnd(sender: IASKAppSettingsViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        PixpieManager.authorize()
        PXPTrafficMonitor.sharedMonitor().reset()
        self.navigationItem.title = transformedValue(PXPTrafficMonitor.sharedMonitor().totalBytesForSession)
    }

    let tokens: [AnyObject] = ["b", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]

    func transformedValue(value: UInt) -> String {
        var convertedValue: Double = CDouble(value)
        var multiplyFactor: Int = 0
        while convertedValue > 1024 && multiplyFactor < tokens.count {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return "\(String(format:"%.2f", (convertedValue)))\(tokens[multiplyFactor])"
    }
}
