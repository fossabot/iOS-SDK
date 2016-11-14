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
    var pickedUrl: NSString?
    var shouldResetCache: Bool = false

    var graphView : PXGraphView?
    
    var timer : Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        //collectionView?.registerClass(ImageCell.self, forCellWithReuseIdentifier: kCellIdentifier)
        self.configStatusView()
        
        self.graphView = PXGraphView.init(frame: CGRect.zero)
        self.graphView?.backgroundColor = UIColor.white
        self.graphView?.pointsNumber = 60
        self.graphView?.alpha = 0.65
        self.view.addSubview(self.graphView!)
        let ti = Int(Date.timeIntervalSinceReferenceDate) + 1
        self.timer = Timer.init(fireAt: Date.init(timeIntervalSinceReferenceDate: TimeInterval(ti)), interval: 1, target: self, selector: #selector(updateGraph), userInfo: nil, repeats: false)
        let runloop = RunLoop.current
        runloop.add(self.timer!, forMode: RunLoopMode.defaultRunLoopMode)
        
        self.navigationItem.title = "0b"
        
        let options = NSKeyValueObservingOptions([.new, .initial])
        PXPTrafficMonitor.shared().addObserver(self, forKeyPath: "totalBytes", options: options, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sdkStateChange), name: NSNotification.Name.PXPStateChange, object: nil)
    }

    func sdkStateChange() {
        if (shouldResetCache) {
            let inset = self.collectionView!.contentInset.top
            self.collectionView?.setContentOffset(CGPoint(x: 0.0, y: -inset), animated: false)
            PXPTrafficMonitor.shared().reset()
            PXP.cleanUp()
            self.navigationItem.title = transformedValue(PXPTrafficMonitor.shared().totalBytes)
            self.collectionView?.reloadData()
            shouldResetCache = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.graphView?.frame = CGRect.init(x: 0, y: self.view.frame.maxY - 100, width: self.view.frame.width, height: 100)
    }

    func updateGraph() {
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
//            self.graphView?.addPoint(PXPTrafficMonitor.shared().lastSample)
//            self.updateGraph()
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(true, animated: animated)
        let options = NSKeyValueObservingOptions([.new, .initial])
        PXP.sharedSDK().addObserver(self, forKeyPath: "state", options: options, context: nil);
    }

    override func viewWillDisappear(_ animated: Bool) {
        PXP.sharedSDK().removeObserver(self, forKeyPath: "state")
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return kSectionsCount
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if (object as? PXP == PXP.sharedSDK()) {
            self.configStatusView()
        }
        else if (object as? PXPTrafficMonitor == PXPTrafficMonitor.shared()) {
            DispatchQueue.main.async(execute: {
                self.navigationItem.title = self.transformedValue(PXPTrafficMonitor.shared().totalBytes)
            })
        }
    }
    
    func configStatusView() {
        self.statusView.backgroundColor = UIColor.clear
        switch PXP.sharedSDK().state {
        case .ready:
            self.statusView.state = .green
        case .failed:
            self.statusView.state = .red
        default:
            self.statusView.state = .yellow
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kImageLinkArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath) as! ImageCell
        var urlString = imageLinksArray[indexPath.item]
        if let range = urlString.range(of: "_z.jpg"){
            urlString.replaceSubrange(range, with: "_n.jpg")
        }
        let url = urlString
        let transform = PXPAutomaticTransform(imageView: cell.imageView!, originUrl: urlString)
        transform.width = 100
        transform.height = 100
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.pxp_transform = transform
        cell.imageView?.pxp_requestImage(url, headers: nil, completion: { (url, image, error) in
            guard let toImage = image as! UIImage?
                else { return }
            guard let imageView = cell.imageView
                else { return }

            UIView.transition(with: imageView,
                duration:0.25,
                options: UIViewAnimationOptions.transitionCrossDissolve,
                animations: { imageView.image = toImage },
                completion: nil)
        })
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.pickedUrl = imageLinksArray[indexPath.item] as NSString?
        performSegue(withIdentifier: kDetailsSegue, sender: collectionView)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == kDetailsSegue) {
            let detailsController = segue.destination as! ImageDetailsController
            detailsController.url = self.pickedUrl
        }
    }

    func itemSize() -> CGSize {
        let itemSize = CGSize(width: self.view.frame.width/4.0, height: self.view.frame.width/4.0)
        return itemSize
    }

    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        return self.itemSize()
    }

    @IBAction func settingsAction(_ sender: AnyObject) {
        let settingsVC = SettingsViewController()
        settingsVC.delegate = self
        let navigationController = UINavigationController(rootViewController: settingsVC)
        navigationController.view.tintColor = UIColor.blue
        self.present(navigationController, animated: true, completion: nil)
    }

    func settingsViewControllerDidEnd(_ sender: IASKAppSettingsViewController!) {
        self.dismiss(animated: true, completion: nil)
        PixpieManager.authorize()
        shouldResetCache = true
    }

    let tokens: [String] = ["b", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]

    func transformedValue(_ value: UInt) -> String {
        var convertedValue: Double = CDouble(value)
        var multiplyFactor: Int = 0
        while convertedValue > 1024 && multiplyFactor < tokens.count {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return "\(String(format:"%.2f", (convertedValue)))\(tokens[multiplyFactor])"
    }
}
