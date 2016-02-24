//
//  ImageCell.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/12/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView : UIImageView?;
    override init(frame: CGRect) {
        super.init(frame: frame)
        let cellImageView = UIImageView(frame: bounds)
        cellImageView.frame = self.contentView.bounds
        cellImageView.contentMode = .Center
        cellImageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        contentView.addSubview(cellImageView)
        imageView = cellImageView
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        imageView?.image = nil
    }
}
