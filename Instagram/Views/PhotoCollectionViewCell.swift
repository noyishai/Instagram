//
//  PhotoCollectionViewCell.swift
//  Instagram
//
//  Created by Ronen on 05/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            // Uses SDWebimage to download the photo from the url
            photo.sd_setImage(with: photoUrl)
        }
    }
}
