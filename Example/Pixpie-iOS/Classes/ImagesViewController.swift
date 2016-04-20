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

private let kCellIdentifier = "kImageCell"
private let kSectionsCount = 1
private let kDetailsSegue = "DetailsSegue"

class ImagesViewController: UICollectionViewController {

    @IBOutlet weak var statusView: PXStatusView!
    let imageLinksArray = kImageLinkArray
    var pickedUrl: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        //collectionView?.registerClass(ImageCell.self, forCellWithReuseIdentifier: kCellIdentifier)
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

        if (object as! PXP == PXP.sharedSDK()) {
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

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize
    {
        return self.itemSize()
    }
}
