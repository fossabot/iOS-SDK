//
//  ImageCell.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/12/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import UIKit
import Pixpie

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView : UIImageView?;
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit();
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit();
    }

    func commonInit() {
        let cellImageView = UIImageView(frame: bounds)
        cellImageView.frame = self.contentView.bounds
        cellImageView.contentMode = .scaleAspectFit
        cellImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(cellImageView)
        imageView = cellImageView
    }

    override func prepareForReuse() {
        super.prepareForReuse();
        imageView?.pxp_cancelLoad();
        imageView?.image = nil
    }
}
