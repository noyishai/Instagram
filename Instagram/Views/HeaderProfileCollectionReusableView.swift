//
//  HeaderProfileCollectionReusableView.swift
//  Instagram
//
//  Created by Ronen on 04/01/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myPostCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    
    var user: User? {
        didSet {
            updateView()
        }
    }
    
    // Query and display current user information
    func updateView() {
        self.nameLabel.text = user!.username
        if let photoUrlString = user!.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            // Uses SDWebimage to download the photo from the url
            self.profileImage.sd_setImage(with: photoUrl)
        }
    }
}
