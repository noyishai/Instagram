//
//  PhotoCollectionViewCell.swift
//  Instagram
//
//  Created by Ronen on 05/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

protocol  PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    
    var delegate: PhotoCollectionViewCellDelegate?
    
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
        
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
        photo.addGestureRecognizer(tapGestureForPhoto)
        photo.isUserInteractionEnabled = true
    }
    
    func photo_TouchUpInside(){
        if let id = post?.id {
            delegate?.goToDetailVC(postId: id)
        }
    }
}
