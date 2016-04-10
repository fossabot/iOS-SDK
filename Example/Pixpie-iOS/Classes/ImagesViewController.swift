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
        collectionView?.registerClass(ImageCell.self, forCellWithReuseIdentifier: kCellIdentifier)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(true, animated: animated)
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

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return kSectionsCount
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kImageLinkArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ImageCell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: indexPath) as! ImageCell
        let url = NSURL(string: imageLinksArray[indexPath.item])
        let transform = PXPTransform(imageView: cell.imageView!)
        transform.fitSize = CGSize(width: 100.0, height: 100.0)
        cell.imageView?.pxp_transform = transform
        cell.imageView?.pxp_requestImage(url)
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
