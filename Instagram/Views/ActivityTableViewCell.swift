//
//  ActivityTableViewCell.swift
//  Instagram
//
//  Created by Noy Ishai on 07/02/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    var notification: Notification? {
        didSet {
            updateView()
        }
    }
    
    // Ovserver which wait to see if the user instance variable is set
    var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    func updateView(){
        
    }
    
    func setupUserInfo(){
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
