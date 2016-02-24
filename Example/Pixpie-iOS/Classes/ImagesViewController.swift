//
//  ImagesViewController.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/12/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit
import Pixpie_iOS

private let kCellIdentifier = "kImageCell"
private let kSectionsCount = 1

class ImagesViewController: UICollectionViewController {

    let imageLinksArray = kImageLinkArray

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.registerClass(ImageCell.self, forCellWithReuseIdentifier: kCellIdentifier)
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
        cell.imageView?.pxp_requestImage(url)
        return cell
    }

}
